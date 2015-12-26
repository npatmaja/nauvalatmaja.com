CURR_DATE = ${shell date +%F}
build-css:
	scss src/css/custom.scss static/css/custom.css
watch-css:
	scss --watch src/css/custom.scss:static/css/custom.css
build:
	hugo -t redlounge
post:
	hugo new post/${CURR_DATE}-${title}.md
serve:
	hugo server -w --buildDrafts -t=redlounge --ignoreCache
