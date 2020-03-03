
FROM swift:5.1.3

WORKDIR /package

COPY . ./

RUN swift package resolve
RUN swift package clean

CMD ["swift", "test"]
