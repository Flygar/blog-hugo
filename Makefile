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
cd public
git add -A
git commit -m ${msg}
git push origin master
cd ..
endef
.PHONY: public
public: 
	@${RUN_PUBLIC}


# hugo-blog
hugo : msg = "backup site ${shell date}"
define RUN_HUGO
git add -A
git commit -m ${msg}
git push origin master
endef
.PHONY: hugo
hugo:
	@${RUN_HUGO}

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

# 流程
# 1. 写完blog后, make test
# 2. 部署前可执行清理public目录， make clear
# 3. 部署： make all


# make test

# make clear
# make -n name="example.com" clear -f Makefile

# make build && make public
# make build && make -n msg="commit message" public -f Makefile

# make hugo
# make -n msg="commit message" hugo -f Makefile
