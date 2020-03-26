# all
.PHONY: all
all: build public hugo 

# Build the project.
# if using anthor theme, replace by `hugo -t <yourtheme>`
.PHONY: build
build: 
	hugo -t maupassant

# public
public : msg = "rebuilding site ${shell date}"
define RUN_PUBLIC
cd public; \
git add -A; \
git commit -m ${msg}; \
git push origin master; \
cd ..
endef
.PHONY: public
public: 
	@${RUN_PUBLIC}


# hugo-blog
hugo : msg = "backup site ${shell date}"
define RUN_HUGO
git add -A; \
git commit -m ${msg}; \
git push origin master
endef
.PHONY: hugo
hugo:
	${RUN_HUGO}

# clear
clear : name = "www.flygar.org"
define RUN_CLEAR
rm -rf public/*
echo ${name} > public/CNAME
endef
.PHONY: clear
clear: 
	${RUN_CLEAR}

# hugo server
.PHONY: test
test: 
	hugo server
