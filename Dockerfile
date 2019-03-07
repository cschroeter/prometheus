# ------------------------------------------------------------------------------
#  Build stage
# ------------------------------------------------------------------------------
FROM arm32v6/alpine:3.9 as builder

ENV PROM_VERSION=2.7.2
ENV PROM_SYSTEM=linux
ENV PROM_ARCH=armv7

WORKDIR /tmp
RUN apk add --no-cache curl
RUN curl --location --output prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.${PROM_SYSTEM}-${PROM_ARCH}.tar.gz;
RUN tar xf prometheus.tar.gz --strip 1

# ------------------------------------------------------------------------------
# Package stage
# ------------------------------------------------------------------------------
FROM arm32v6/alpine:3.9

COPY --from=builder /tmp/prometheus /bin/prometheus
COPY --from=builder /tmp/promtool /bin/promtool
COPY --from=builder /tmp/prometheus.yml /etc/prometheus/prometheus.yml
COPY --from=builder /tmp/console_libraries/ /usr/share/prometheus/console_libraries/
COPY --from=builder /tmp/consoles/ /usr/share/prometheus/consoles/

EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
  "--storage.tsdb.path=/prometheus", \
  "--web.console.libraries=/usr/share/prometheus/console_libraries", \
  "--web.console.templates=/usr/share/prometheus/consoles" ]