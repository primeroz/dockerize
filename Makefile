.SILENT :
.PHONY : dockerize clean fmt

TAG:=`git describe --abbrev=0 --tags`
LDFLAGS:=-X main.buildVersion=$(TAG) -s -w

all: dockerize

deps:
	go mod download

dockerize:
	echo "Building dockerize"
	go install -ldflags "$(LDFLAGS)"

dist-clean:
	rm -rf dist
	rm -rf SHA256SUMS
	rm -f dockerize-*.tar.gz

dist: deps dist-clean
	mkdir -p dist/alpine-linux/amd64 && GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -a -tags netgo -installsuffix netgo -o dist/alpine-linux/amd64/dockerize
	mkdir -p dist/linux/amd64 && GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o dist/linux/amd64/dockerize
	mkdir -p dist/linux/386 && GOOS=linux GOARCH=386 go build -ldflags "$(LDFLAGS)" -o dist/linux/386/dockerize
	mkdir -p dist/linux/armel && GOOS=linux GOARCH=arm GOARM=5 go build -ldflags "$(LDFLAGS)" -o dist/linux/armel/dockerize
	mkdir -p dist/linux/armhf && GOOS=linux GOARCH=arm GOARM=6 go build -ldflags "$(LDFLAGS)" -o dist/linux/armhf/dockerize
	mkdir -p dist/linux/arm64 && GOOS=linux GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o dist/linux/arm64/dockerize
	mkdir -p dist/darwin/amd64 && GOOS=darwin GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o dist/darwin/amd64/dockerize

release: dist
	tar -czf dockerize-alpine-linux-amd64-$(TAG).tar.gz -C dist/alpine-linux/amd64 dockerize
	tar -czf dockerize-linux-amd64-$(TAG).tar.gz -C dist/linux/amd64 dockerize
	tar -czf dockerize-linux-386-$(TAG).tar.gz -C dist/linux/386 dockerize
	tar -czf dockerize-linux-armel-$(TAG).tar.gz -C dist/linux/armel dockerize
	tar -czf dockerize-linux-armhf-$(TAG).tar.gz -C dist/linux/armhf dockerize
	tar -czf dockerize-linux-arm64-$(TAG).tar.gz -C dist/linux/arm64 dockerize
	tar -czf dockerize-darwin-amd64-$(TAG).tar.gz -C dist/darwin/amd64 dockerize
	sha256sum dockerize-* > SHA256SUMS
