# Logging

*Network* libraries allow you to see tracing of each ``Request`` sent by a web client 
and each ``Response`` received from a server. It uses *debug* logging level and shows detailed 
description of request and response. As these logs doesn't make sense in production, they work only 
when you run your app from Xcode.

## Enable logging

To enable logging you need to set environment variable `NETWORK_LOGGING` to `ON` or `ON CURL` in
settings of your build scheme. Regardless value of variable each response will be logged. In case of
`ON` value each request will be logged in the form of list of request's values. In case of `ON CURL`
each request will be logged in the form of *cURL* command.

## Logs filtering

Loggers use *InstrumentBox.Network.WebCore* and *InstrumentBox.Network.WebStub* subsystems and
*Request*, *Request cURL*, and *Response* categories. So you are allowed to filter logs using this
values.
