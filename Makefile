CURR_DATE = ${shell date +%F}
CURR_DIR = ${shell pwd}
TEMP_DIR = temp
PUB_DIR = public

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

.PHONY: build post clean

clean:
	rm -rf temp dev

# Deploy to github Pages
step-deploy-prepare-dirs:
	mkdir ${TEMP_DIR}
	cp -r ${PUB_DIR}/.git ${TEMP_DIR} && cp ${PUB_DIR}/.gitignore ${TEMP_DIR}
	rm -rf ${PUB_DIR}

step-deploy-after-build:
	touch ${PUB_DIR}/.nojekyll
	cp -r ${TEMP_DIR}/.git ${PUB_DIR} && cp ${TEMP_DIR}/.gitignore ${PUB_DIR}

step-deploy-commit-push:
	pushd ${PUB_DIR} > /dev/null
	git add -A
	git commit -m "`date`"
	git push origin master
	popd > /dev/null

deploy: clean step-deploy-prepare-dirs build step-deploy-after-build step-deploy-commit-push
