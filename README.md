# Task 1: Systemd Service in a Docker Container

This document describes how to set up and run a Python HTTP server as a `systemd` service inside a Docker container.

---

## **Step 1: Python HTTP Server Code**

Create a file named `script.py` with the following content:

```python
from http.server import SimpleHTTPRequestHandler
from socketserver import TCPServer

PORT = 8080

class CustomHandler(SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Disable console logs (optional).

if __name__ == "__main__":
    with TCPServer(("", PORT), CustomHandler) as httpd:
        print(f"Serving on port {PORT}")
        httpd.serve_forever()
```
## **Step 2: Create a systemd Unit File**

Create a file named `myapp.service` with the following content:

```ini
[Unit]
Description=Simple Python HTTP Server
After=network.target

[Service]
ExecStart=/usr/bin/python3 /app/script.py
Restart=always
User=root
WorkingDirectory=/app

[Install]
WantedBy=multi-user.target
```