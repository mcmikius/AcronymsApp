FROM swift:4.2 as builder
RUN apt-get -qq update && apt-get -q -y install \
  tzdata \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN mkdir -p /build/lib && \
  cp -R /usr/lib/swift/linux/*.so /build/lib
RUN swift build -c release && \
  mv `swift build -c release --show-bin-path` /build/bin

# Production image
FROM ubuntu:16.04
RUN apt-get -qq update && apt-get install -y \
  libicu55 libxml2 libbsd0 libcurl3 libatomic1 \
  tzdata \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /build/bin/Run .
COPY --from=builder /build/lib/* /usr/lib/
# You need the next line if your app serves static resources
# from the Public directory
COPY --from=builder /app/Public ./Public
# You need the next line if your app uses Leaf
COPY --from=builder /app/Resources ./Resources
ENTRYPOINT ./Run serve --env production --hostname 0.0.0.0 \
  --port 8080
