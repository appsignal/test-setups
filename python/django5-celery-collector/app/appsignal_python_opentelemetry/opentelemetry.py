import os
import subprocess
import socket

from opentelemetry import trace, metrics
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import (
    Counter,
    Histogram,
    MeterProvider,
    ObservableCounter,
    ObservableGauge,
    ObservableUpDownCounter,
    UpDownCounter,
)
from opentelemetry.sdk.metrics.export import (
    AggregationTemporality,
    PeriodicExportingMetricReader,
)
from opentelemetry.exporter.otlp.proto.http.trace_exporter import (
    OTLPSpanExporter
)
from opentelemetry.exporter.otlp.proto.http.metric_exporter import (
    OTLPMetricExporter
)


class Appsignal:
    def __init__(self, service_name) -> None:
        # Specify AppSignal collector location
        collector_host = "http://appsignal-collector:8099"

        # Add AppSignal and app configuration
        resource = Resource(attributes={
            "appsignal.config.name":
                os.environ.get("APPSIGNAL_APP_NAME") or "",
            "appsignal.config.environment":
                os.environ.get("APPSIGNAL_APP_ENV") or "",
            "appsignal.config.push_api_key":
                os.environ.get("APPSIGNAL_PUSH_API_KEY") or "",
            "appsignal.config.revision": "test-setups",
            "appsignal.config.language_integration": "python",
            "appsignal.config.filter_request_parameters": [
                "password",
                "email",
                "cvv"
                ],
            "appsignal.config.filter_request_session_data": [
                "token",
                ],
            "appsignal.config.filter_function_parameters": [
                "hash",
                "salt",
                ],
            "host.name": socket.gethostname(),
            # Customize the service name
            "service.name": service_name,
            "appsignal.config.app_path": os.getcwd(),
        })
        trace_provider = TracerProvider(resource=resource)

        # Configure the OpenTelemetry HTTP traces exporter
        span_processor = BatchSpanProcessor(
            OTLPSpanExporter(endpoint=f"{collector_host}/v1/traces")
        )
        trace_provider.add_span_processor(span_processor)
        trace.set_tracer_provider(trace_provider)

        metric_exporter = OTLPMetricExporter(
            endpoint=f"{collector_host}/v1/metrics",
        )
        metric_reader = PeriodicExportingMetricReader(
            metric_exporter,
            export_interval_millis=10000
        )
        metric_provider = MeterProvider(
            resource=resource,
            metric_readers=[metric_reader]
        )
        metrics.set_meter_provider(metric_provider)
