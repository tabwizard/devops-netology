#!/usr/bin/env python3
import sentry_sdk
sentry_sdk.init(
    "https://c022ac48afbf4e6f8d5cef032a5295ed@o1060342.ingest.sentry.io/6049806",

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=1.0
)

print('hello world')

# division_by_zero = 1 / 0
symbol = "word"
error = symbol * 3 - "abc"
