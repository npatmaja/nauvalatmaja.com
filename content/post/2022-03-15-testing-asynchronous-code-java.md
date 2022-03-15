---
summary: "Testing multi-threaded code is tricky, the test and the code under test most likely are run under different threads. Here, we will discuss how to
deal with the issue based on the book Growing Object-Oriented Software Guided by Tests"
tags: [java, concurrent, testing, tdd, asynchronous, multithreading]
date: 2022-03-15T08:18:16+07:00
title: "Testing Asycnhronous Code in Java"
categories: [Programming, Development]
series: []
keywords: [tdd, testing, testing asynchronous code, java, unit test]
socialsharing: true
draft: false
totop: true
---
Testing asynchronous code is tricky. In a typical case, we are mostly dealing with a single
threaded code which means the test and the program (or object) under test are run in the same thread.
However, in a concurrent setup, the test might be run in a different thread from part of the program
under test. This is problematic when the program using fire-and-forget asynchronous type of concurrency
where the program does not need to know what are the outcomes of its children processes.
The easiest workaround is to make the test _wait_ for the children processes finished using `Thread.sleep`. Still,
the aforementioned workaround may be unstable when run in different environment with different hardware
configuration, e.g., CI runner. In the local machine the test may pass but intermittently fails in CI.

In the [Growing Object Oriented Software Guided by Tests](http://www.growing-object-oriented-software.com/)
the authors write two dedicated chapters related to test and multi-threading code (chapter 27 and 28). Those
chapters are intriguing as I have an experience struggling to test a multi-threaded code. While it passes
all unit tests in the local machine but keep failing in the CI job.

In my opinion, there are two significant takeaways
from the chapters to handle such issue:
1. Separate the concurrency policy and the functionality
2. Asynchronous codes testing strategy

## Separate concurrency policy and functionality
In short, separation between concurrency policy and the functionality is achieved by making the `Executor` service
part of the injected dependencies. Let's say we have a program that sends an email to a list of recipients asynchronously,
we call it `NotificationHandler`. The class calls a `NotificationGateway#fire` to actually send the email.

```java
public interface NotificationGateway {
    void fire(String anyString);
}

public class NotificationHandler {
    private final NotificationGateway notification;
    private final Executor executor;

    public NotificationHandler(NotificationGateway notification, Executor executor) {
        this.notification = notification;
        this.executor = executor;
    }

    public void handleWithExecutor(List<String> recipients) {
        for (String recipient : recipients) {
            executor.execute(new Runnable() {
                @Override
                public void run() {
                    sendNotification(recipient);
                }
            });
        }
    }

    @SneakyThrows
    private void sendNotification(String emailAddress) {
        notification.fire(emailAddress);
    }
}
```

By making the `Executor` injected, we can actually wait for the pool to terminate before asserting the system under test.

```java
class FireAndForgetTest {
    private final List<String> sendToAddresses = Arrays.asList(
      // redacted
      );
    private NotificationGateway notification;
    private NotificationHandler handler;
    private ExecutorService executor;
    private NotificationTrace<String> trace;

    @BeforeEach
    void setup() {
        notification = mock(NotificationGateway.class);
        trace = new NotificationTrace<>();
        executor = Executors.newFixedThreadPool(5);
        handler = new NotificationHandler(notification, executor);
    }

    @Nested
    class UsingExecutor {
        @Test
        @SneakyThrows
        void givenAList_whenHandleWithExecutor_shouldCallNotificationGateway() {
            Logger log = Logger.builder().start(System.currentTimeMillis()).build();

            doAnswer(invocation -> {
                log.logExecution(Thread.currentThread(), "executes notification#fire");
                Thread.sleep(1000);
                return null;
            }).when(notification).fire(anyString());
    
            handler.handleWithExecutor(sendToAddresses);

            executor.shutdown();
            log.logExecution(Thread.currentThread(), "executor shutdown");
            
            executor.awaitTermination(10000, TimeUnit.MILLISECONDS);
            log.logExecution(Thread.currentThread(), "executor terminated");
            
            verify(notification, times(sendToAddresses.size())).fire(anyString());
        }
    }
}
```
Here, we stub the `fire` method to simulate a long running process with `Thread.sleep(1000)`. The `executor` needs to be shutdown
after the method under test has been called. Calling `executor.shutdown` initiates orderly shutdown and no new tasks will be accepted;
the already submitted tasks will still be executed. The `executor.awaitTermination` will block the thread until all the tasks are completed
after a shutdown request. 

```
[thread main] executor shutdown after [14 ms] from initial execution time
[thread pool-1-thread-4] executes notification#fire after [18 ms] from initial execution time
[thread pool-1-thread-3] executes notification#fire after [18 ms] from initial execution time
[thread pool-1-thread-1] executes notification#fire after [18 ms] from initial execution time
[thread pool-1-thread-5] executes notification#fire after [18 ms] from initial execution time
[thread pool-1-thread-2] executes notification#fire after [18 ms] from initial execution time
[thread pool-1-thread-4] executes notification#fire after [1020 ms] from initial execution time
[thread pool-1-thread-3] executes notification#fire after [1021 ms] from initial execution time
[thread pool-1-thread-1] executes notification#fire after [1023 ms] from initial execution time
[thread pool-1-thread-2] executes notification#fire after [1023 ms] from initial execution time
[thread pool-1-thread-5] executes notification#fire after [1023 ms] from initial execution time
[thread main] executor terminated after [2028 ms] from initial execution time
```

We can see from the log above that the tasks' actual execution are after the shutdown request have been made while the actual termination
waits after all the tasks has been completed.

## Asycnronous code testing strategy
There are two strategy mentioned in the last chapter of the book namely _listening_ and _sampling_.
_Listening_ means that the test should able to listen events that a systems sends out when executing asynchronous tasks.
On the other hand, _sampling_ requires the test to sample observable state.

### Listening: Capturing Notifications
We will use the same `NotificationHandler` class to elaborate the detail of the _listening_ mechanism.
As the name suggest, we need an object that captures events sent by the observed system, called `NotificationTrace` (see 
[here](https://github.com/npryce/goos-code-examples/blob/master/testing-asynchronous-systems/src/book/example/async/notifications/NotificationTrace.java) for the original code). The class provide a method `append` that needs be
called by the observed system. The append process is wrapped by a `synchronized` block to make sure that no race
condition occurred.
The interesting part actually in the assertion method `NotificationTrace#containsNotificationIn` where it blocks the thread and
evaluate whether the criteria is satisfied or timed-out. The actual criteria evaluation is delegated to the `NotificationListStream` class.
This part is different from the original code as what we want to assert is
different: we want to assert that all the emails are sent to the correct recipient list. Hence, if we want to
have another assertion, let's say the size of recipient list is equal to the size of the original recipient list,
we might have to write another method to express the assertion. Well, it might be an opportunity to refactor the
`NotificationTrace` class to have a general assertion method that can work with most criteria for further improvement.

```java
@Setter
@Getter
public class NotificationTrace<T> {
    private final Object tracelock = new Object();
    private final List<T> trace = new ArrayList<>();
    private long timeoutMs = 1000L;

    public void append(T message) {
        synchronized (tracelock) {
            trace.add(message);
            tracelock.notifyAll();
        }
    }

    public void containsNotificationIn(Matcher<Iterable<? extends T>> criteria) throws InterruptedException {
        Timeout timeout = new Timeout(timeoutMs);
        synchronized (tracelock) {
            NotificationListStream<T> stream = new NotificationListStream<>(trace, criteria);
            while (!stream.hasMatched()) {
                if (timeout.hasTimedOut()) {
                    throw new AssertionError(failureDescriptionFrom(criteria));
                }
                timeout.waitOn(tracelock);
            }
        }
    }

    private String failureDescriptionFrom(Matcher<? extends Object> criteria) {
        // redacted
    }
}

@RequiredArgsConstructor
public class NotificationListStream<T> {
    private final List<T> notifications;
    private final Matcher<Iterable<? extends T>> criteria;

    public boolean hasMatched() {
        return criteria.matches(notifications);
    }
}
```

The following snippet is the unit test code omitting instantiation of the `NotificationTrace<String> trace` object (commented for brevity). To simulate how the observed system sent out events, the method `fire` is stubbed and calls the `trace.append` method to notify the listener (the `trace` object)
```java
// the test
// private NotificationTrace<String> trace = new NotificationTrace<>();

@SneakyThrows
@Test
void givenAList_whenHandleWithExecutor_shouldCallNotificationGateway() {
    trace.setTimeoutMs(10000L);
    doAnswer(invocation -> {
        Thread.sleep(1000);
        trace.append(invocation.getArgument(0));
        return null;
    }).when(notification).fire(anyString());

    handler.handleWithExecutor(sendToAddresses);

    trace.containsNotificationIn(
        containsInAnyOrder(convertToArray(sendToAddresses)));
}
```
The obvious precondition is to have the system under test have the capability to send events, or we need to design it that way.
The system does not necessarily have dependency to the `NotificationTrace`, however, it should have
a dependency to an interface that send those events. Then, we can create an implementation of the interface that
calls `NotificationTrace` or simply mock it.

### Sampling: Polling for changes
When we do not have the option to make the system sends events or it is not make sense to do so, another way
to test asynchronous code is by observe the state of the system time to time until the expectation criteria
is matched or time out occurred. The test will actively polling the system to get its latest observed changes.
The book introduces two main constructs that allow us to sampling the state of a system under test: a `Poller`
and a `Probe`. A `Probe` is an interface to capture an observable state of a system under test and validate an assertion based
on the state. It provides two significant methods namely `sample` and `isSatisfied` for sampling the state and
validating an assertion respectively.

```java
@Getter
@Setter
@AllArgsConstructor
public class Poller {
    private long timeoutMillis;
    private long pollDelayMillis;

    public void check(Probe probe) throws InterruptedException {
        Timeout timeout = new Timeout(timeoutMillis);
        while (!probe.isSatisfied()) {
            if (timeout.hasTimedOut()) {
                throw new AssertionError(describeFailureOf(probe));
            }
            Thread.sleep(pollDelayMillis);
            probe.sample();
        }
    }

    private String describeFailureOf(Probe probe) {
        // redacted
    }

    public static void assertEventually(
        Probe probe,
        long timeoutMillis,
        long delayMillis)
    throws InterruptedException {
        new Poller(timeoutMillis, delayMillis).check(probe);;
    }
}

public interface Probe {
    boolean isSatisfied();
    void sample();
    void describeAcceptanceCriteriaTo(Description d);
    void describeFailureTo(Description d);
}

public class Timeout {
    private final long endTime;

    public Timeout(long duration) {
        this.endTime = System.currentTimeMillis() + duration;
    }

    public boolean hasTimedOut() {
        return timeRemaining() <= 0;
    }

    public void waitOn(Object lock) throws InterruptedException {
        long waitTime = timeRemaining();
        if (waitTime > 0) lock.wait(waitTime);
    }

    private long timeRemaining() {
        return endTime - System.currentTimeMillis();
    }
}
```

The method `check` in class `Poller` is waiting (using `while` loop) until the specified assertion criteria is
satisfied or a timeout is reached. The fundamental difference between the _listening_ method is that the _sampling_
method does not capture the system under test's state in real time, rather, in an a specified interval configured by
the `pollDelayMillis` variable. To actually assert using this mechanism, the `Poller` provides a static assertion method `assertEventually` that takes
a `probe`, `timeoutMillis` and `delayMillis` as its parameters then it simply instantiates a new `Poller` object and
calls the method `check` that initiates the sampling procedure.

```java
// the test method
@SneakyThrows
@Test
void givenAList_whenHandleWithExecutor_shouldCallNotificationGateway() {
    doAnswer(invocation -> {
        Thread.sleep(1000);
        return null;
    }).when(notification).fire(anyString());

    handler.handleWithExecutor(sendToAddresses);
    
    assertEventually(
        fireNotificationTo(notification, is(sendToAddresses.size())),
        10000L, 1000L);
}

// NotificationProbe
public class NotificationProbe {
    private static final int NOT_SET = -1;

    public static Probe fireNotificationTo(
        NotificationGateway notification, final Matcher<Integer> matcher) {
        return new Probe() {
            private int count = NOT_SET;

            @Override
            public boolean isSatisfied() {
               return count != NOT_SET && matcher.matches(count);
            }

            @Override
            public void sample() {
                ArgumentCaptor<String> captor = ArgumentCaptor.forClass(String.class);
                verify(notification, atLeastOnce()).fire(captor.capture());
                count = captor.getAllValues().size();
            }

            @Override
            public void describeAcceptanceCriteriaTo(Description d) {
                d.appendText("notification")
                .appendText(" has been called ")
                .appendDescriptionOf(matcher);
            }

            @Override
            public void describeFailureTo(Description d) {
                d.appendText("call count was ").appendValue(count);
            }
        };
    }
}
```
In this sampling observation method, we need to define the `Probe` to capture significant states of a system
under test and to provide criteria matcher evaluation based on those states. In our case, the `Probe` definition
is built in a `static` helper method `notification` in class `NotificationProbe`.

At the end, the three discussed mechanisms are not mutually exclusive. One mechanism is not inherently superior to others.
We might ended using only one of them or combination out of the three depends on the situation and the objective of the system.

Please see this [github repository](https://github.com/npatmaja/concurrency-goos-excercise) for the complete implementation.
