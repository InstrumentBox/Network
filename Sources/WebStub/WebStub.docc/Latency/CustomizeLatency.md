# Customize Latency

Read how to simulate and customize latency.

## Overview

``StubbedWebClient`` also allows you to simulate latency for requests when response is returned from 
file. The Library provides you with ``Latency`` protocol and couple of its implementations.

## Enable latency simulation

To enable latency simulation you just need set latency implementation in a corresponding property of
``StubbedWebClientConfiguration`` which is `nil` by default.

```swift
configuration.latency = ExactLatency(value: 3.0)
```

This latency implementation uses the same value (3 seconds) for each request web client sends. The 
second implementation provided by the library generated random latency in between given values for 
each request.

```swift
configuration.latency = RandomLatency(range: 3.0...5.0)
```

## Create custom latency

You are also allowed to create your own latency implementation. All you need is just to conform to
``Latency`` protocol.

```swift
import Web
import WebStub

class MyLatency: Latency {
   func value(for request: some Request) -> TimeInterval {
      ...
   }
}
```
