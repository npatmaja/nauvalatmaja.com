GH_PAGES_REPO = git@github.com:npatmaja/npatmaja.github.io.git
CURR_DATE = ${shell date +%F}
CURR_DIR = ${shell pwd}
TEMP_DIR = temp
PUB_DIR = public

.PHONY: build post clean

build-css:
	@scss src/css/custom.scss static/css/custom.css
watch-css:
	@scss --watch src/css/custom.scss:static/css/custom.css
build:
	@hugo -t redlounge
post:
	@hugo new post/${CURR_DATE}-${title}.md
serve:
	@hugo server -w --buildDrafts -t=redlounge --ignoreCache

clean:
	@rm -rf temp dev

# deployment setup,
# make sure ${PUB_DIR} has been added to .gitignore.
# Actually it just cloge the github pages repository
setup-deploy:
	git clone ${GH_PAGES_REPO} ${PUB_DIR}


# Deployment steps
# 1. Create temporary directory to put .git and .gitignore temporaryly
step-deploy-prepare-dirs:
	mkdir ${TEMP_DIR}
	cp -r ${PUB_DIR}/.git ${TEMP_DIR} && cp ${PUB_DIR}/.gitignore ${TEMP_DIR}
	rm -rf ${PUB_DIR}

# 2. Build the static files using task build
# 3. Create .nojekyll and put back .git and .gitignore out of temporary
# 	 directory
step-deploy-after-build:
	touch ${PUB_DIR}/.nojekyll
	cp -r ${TEMP_DIR}/.git ${PUB_DIR} && cp ${TEMP_DIR}/.gitignore ${PUB_DIR}

# 4. Go to ${PUB_DIR}, commit, push to github repository and go back
# 	 to previous directory, i.e., root project
step-deploy-commit-push:
	pushd ${PUB_DIR} > /dev/null && git add -A && \
	git commit -m "`date`" && git push -f origin master && popd > /dev/null

# deploy to Github Pages
deploy: clean step-deploy-prepare-dirs build step-deploy-after-build step-deploy-commit-push

# Commit to nauvalatmaja.com
step-commit-push-post:
	cd ${CURR_DIR}
	git add -A
	git commit -m "Add new/edit post `date`"
	git push origin master

deploy-post: deploy step-commit-push-post clean
