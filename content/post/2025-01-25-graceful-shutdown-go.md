---
summary: "Graceful shutdown is an important mechanism to deal with suddent sever shutdown or termnination signal. Here, we will explore how to implement graceful shutdown ig Go and how to test it."
tags: [software, server]
date: 2025-01-25T08:18:16+07:00
title: "Graceful Shutdown in Go HTTP Server"
categories: [Programming, Development]
series: []
keywords: []
socialsharing: true
draft: false
totop: true
---
Graceful shutdown is a mechanism that refers to handle process termination properly. This is important to make sure the data integrity is not affected when a termination/interrupt signal is received. Imagine the termination signal suddenly received by the application, if without proper  shutdown handling, the ongoing transactions will be terminated which may be compromising the data integrity. 

In Go, fortunately the graceful shutdown is part of the standard library. To trigger the process we just need to call `http.Server.Shutdown()` method. The method takes a `context.Context` as its parameter and returns `error`. The recommended behavior is to use a `context.WithTimeOut` . The following is a custom `struct` Server that encapsulate the start and shutdown mechanism.

```go
type Server struct {
	httpServer *http.Server
	ShutdownTimeoutSeconds int
}

func NewServer(config *ServerConfig, handler *http.ServeMux) *Server {
	httpServer := &http.Server{
		Addr:              fmt.Sprintf("%s:%d", config.Host, config.Port),
		Handler:           handler,
		ReadTimeout:       config.ReadTimeout,
		WriteTimeout:      config.WriteTimeout,
		ReadHeaderTimeout: config.ReadHeaderTimeout,
		IdleTimeout:       config.IdleTimeout,
	}
	return &Server{
		httpServer:             httpServer,
		ShutdownTimeoutSeconds: config.ShutdownTimeoutSeconds,
	}
}

func (s *Server) Start() error {
	errorChan := make(chan error, 1)
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)

	go func() {
		slog.Info("Starting server at", slog.String("Addr", s.httpServer.Addr))
		if err := s.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			errorChan <- err
		}
	}()

	select {
	case err := <-errorChan:
		return fmt.Errorf("Fail to start the server. error=%v", err)
	case sig := <-shutdown:
		slog.Info("Shutdown signal received: %v", slog.Any("sig", sig))
		// add cleanup resources here if necessary, i.e., close database connections,
		// close cache connections, etc
		return s.Shutdown()
	}
}

func (s *Server) Shutdown() error {
	slog.Info("Initiating shutdown", slog.Time("now", time.Now()))
	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(s.ShutdownTimeoutSeconds)*time.Second)
	defer cancel()

	return s.httpServer.Shutdown(ctx)
}
```

In the method `Start` the server not only simply listen and serve to a certain port, but it also needs to listen to termination signals from the [`os.Signal`](https://pkg.go.dev/os/signal) , e.g., `kill` command or `ctrl + c` . This is done by creating a designated channel of `os.Signal` with length `1` then relay the os signal to the channel through `signal.Notify`.

```go
shutdown := make(chan os.Signal, 1)
signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)
```

A goroutine wraps the `http.Server.ListenAndServe` call so that it won’t block the execution. 

The error checking `err != http.ErrServerClosed` is important to make sure that the server is running. The error itself is returned when the `Shutdown` or `Close` method is called. During the test, without this error checking the server will not work properly as the gap between start and shutdown is in milliseconds.

Then, a `select` block statement blocks the execution and wait for error and shutdown signal. When shutdown signal is received the server then call the `Shutdown` method.

```go
go func() {
	slog.Info("Starting server at", slog.String("Addr", s.httpServer.Addr))

	if err := s.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		errorChan <- err
	}
}()

select {
case err := <-errorChan:
	return fmt.Errorf("Fail to start the server. error=%v", err)
case sig := <-shutdown:
	slog.Info("Shutdown signal received: %v", slog.Any("sig", sig))
	// add cleanup resources here if necessary, i.e., close database connections,
	return s.Shutdown()
}
```

The `Shutdown` code is fairly straightforward, first we create a context with timeout, next we call the `http.Server.Shutdown` with the context as its parameter. Based on the [documentation](https://pkg.go.dev/net/http#Server.Shutdown), when the server initiate shutdown, it will do the following:

1. Closes all open listeners
2. Closes idle connections
3. Wait indefinitely for connections to return to idle (complete the processes) and then shut down. If the context expires before shutdown is complete, Shutdown returns the context’s error, otherwise it returns any error returned from the closing the Server’s listener.

Based on the aforementioned steps, the Shutdown never closed any connections forcefully even when the timeout context expires. It just wait indefinitely until all requests complete and then shut down.

Now, how do we test the graceful shutdown behavior? The idea is to use a table testing and in each scenario we will call an endpoint (can be the slow or a fast one) and asserts if the response is correct or if timeout the Shutdown will return the correct error.

```go
func TestGracefulShutdown(t *testing.T) {
	port := 9090
	host := fmt.Sprintf("http://%s:%d", "localhost", port)
	mux := http.NewServeMux()
	mux.HandleFunc("GET /fast", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
	mux.HandleFunc("GET /slow", func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(2 * time.Second)
		w.WriteHeader(http.StatusOK)
	})

	tests := []struct {
		testName       string
		clientRequest  func() []*http.Response
		shutdownDelay  time.Duration
		expectTimeout  bool
		timeoutSeconds int
	}{
		{
			testName: "Should complete fast request during shutdown",
			clientRequest: func() []*http.Response {
				resp, err := http.Get(fmt.Sprintf("%s/fast", host))
				if err != nil {
					t.Fatal("Fail to execute request", err)
				}

				return []*http.Response{resp}
			},
			expectTimeout:  false,
			shutdownDelay:  100 * time.Millisecond,
			timeoutSeconds: 5,
		},
		{
			testName: "Should complete slow request during shutdown",
			clientRequest: func() []*http.Response {
				resp, err := http.Get(fmt.Sprintf("%s/slow", host))
				if err != nil {
					t.Fatal("Fail to execute request", err)
				}

				return []*http.Response{resp}
			},
			expectTimeout:  false,
			shutdownDelay:  100 * time.Millisecond,
			timeoutSeconds: 5,
		},
		{
			testName: "Should return timeout exceeded when timeout exceeds",
			clientRequest: func() []*http.Response {
				resp, err := http.Get(fmt.Sprintf("%s/slow", host))
				if err != nil {
					t.Fatal("Fail to execute request", err)
				}

				return []*http.Response{resp}
			},
			expectTimeout:  true,
			shutdownDelay:  100 * time.Millisecond,
			timeoutSeconds: 1,
		},
	}

	for _, tt := range tests {
		t.Run(tt.testName, func(t *testing.T) {
			server := NewServer(&ServerConfig{
				Port:                   port,
				ShutdownTimeoutSeconds: tt.timeoutSeconds,
			}, mux)

			// start server
			var wg sync.WaitGroup
			wg.Add(1)
			go func() {
				wg.Done()
				err := server.Start()
				if err != nil {
					t.Fatalf("Fail to start server. error=%v", err)
				}
			}()

			// wait for the server to be ready
			time.Sleep(100 * time.Millisecond)
			var responses []*http.Response
			go func() {
				responses = tt.clientRequest()
			}()

			// shutdown delay
			time.Sleep(tt.shutdownDelay)

			err := server.Shutdown()

			// assert shutdown behaviour
			if tt.expectTimeout {
				if err != context.DeadlineExceeded {
					t.Errorf("Expected timeout. got=%v", err)
				}
			} else {
				if err != nil {
					t.Errorf("Unexpected shutdown. got=%v", err)
				}
			}

			// verify all requests are completed
			for _, resp := range responses {
				if resp.StatusCode != http.StatusOK {
					t.Errorf("Status code is not %v. go=%v", http.StatusOK, resp.StatusCode)
				}
			}
		})
	}
}
```

In the third scenario, the test examines whether the server returns `context.DeadlineExceeded` when shutdown. The `expectTimeout` is set to true to assert the error returned by the `Shutdown` method and the timeoutSeconds is set to `1` second which is lesser than the sleep duration in the `/slow` endpoint (5 seconds).

```go
{
	testName: "Should return timeout exceeded when timeout exceeds",
	clientRequest: func() []*http.Response {
		resp, err := http.Get(fmt.Sprintf("%s/slow", host))
		if err != nil {
			t.Fatal("Fail to execute request", err)
		}

		return []*http.Response{resp}
	},
	expectTimeout:  true,
	shutdownDelay:  100 * time.Millisecond,
	timeoutSeconds: 1,
},
```

In conclusion, graceful shutdown is an important feature that needs to be implemented to a web server to reduce data error due to data integrity issues. The implementation is fairly straight forward in Go. Furthermore the mechanism is highly testable.