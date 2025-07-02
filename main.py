#!/usr/bin/env python3
"""
Minimal Python file required by App Engine.
All requests are handled by static file handlers in app.yaml.
This file is never executed.
"""

def app(environ, start_response):
    """WSGI application that should never be called."""
    start_response('404 Not Found', [('Content-Type', 'text/plain')])
    return [b'Static file handler should have caught this request.']

if __name__ == '__main__':
    # This should never run in production
    print("This file should not be executed - check app.yaml configuration") 