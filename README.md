# DevOps Assignment Deliverables

## Task 1: Deploy a Systemd Service

### **Application Code**

Python HTTP server code (`script.py`):

```python
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8080

class CustomHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"Hello, World!")

if __name__ == "__main__":
    with HTTPServer(("", PORT), CustomHandler) as httpd:
        print(f"Serving on port {PORT}")
        httpd.serve_forever()
```

### **Systemd Unit File**

`myapp.service`:

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

### **Deployment Instructions**

1. Place `script.py` in `/app` directory.
2. Ensure Python 3 is installed on the system (`which python3`).
3. Copy the Systemd unit file to `/etc/systemd/system/`.
4. Reload Systemd and start the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start myapp.service
   sudo systemctl enable myapp.service
   ```
5. Verify the service is running:
   ```bash
   sudo systemctl status myapp.service
   tail -f /var/log/myapp.log
   ```

---

## Task 2: Docker-Based Deployment

### **Dockerfile**

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY script.py .

CMD ["python3", "script.py"]
```

### **docker-compose.yml**

```yaml
version: '3.8'

services:
  app:
    image: python-systemd-app
    container_name: myapp
    ports:
      - "8080:8080"  
    deploy:
      replicas: 1  
    networks:
      - app-network

  app_replica:
    image: python-systemd-app
    container_name: myapp-replica
    ports:
      - "8081:8080"  
    deploy:
      replicas: 1
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    container_name: nginx-proxy
    ports:
      - "80:80"  
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app
      - app_replica
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### **NGINX Configuration**

`nginx.conf`:

```nginx
user  nginx;
worker_processes  1;

events {
    worker_connections 1024;
}

http {
    upstream backend {
        server myapp:8080;
        server myapp-replica:8081; 
    }
    include       mime.types;
    default_type  application/octet-stream;

    server {
        listen       80;
        server_name  localhost;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```

### **Deployment Instructions**

1. Build and start the containers:
   ```bash
   docker-compose up --build
   ```
2. Access the application at `http://localhost`.

---

## Task 3: Kubernetes Deployment

### **Deployment Manifest**

`deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
  labels:
    app: python-app
spec:
  replicas: 2  
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
    spec:
      containers:
      - name: python-app
        image: eminebeyzagumus/python-systemd-app:latest 
        ports:
        - containerPort: 8080
```

### **Service Manifest**

`service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: python-app-service
spec:
  selector:
    app: python-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

### **Deployment Instructions**

1. Apply the manifests:
   ```bash
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```
2. Verify pods and service:
   ```bash
   kubectl get pods
   kubectl get svc
   ```
3. Access the application via the LoadBalancer external IP or use `minikube service` for local testing:
   ```bash
   minikube service python-app-service
   ```

---

## Task 4: Debugging and Troubleshooting

### **Scenario 1: Systemd Service Debugging**

#### Issue:

- `ExecStart` points to an incorrect Python path.

#### Resolution:

- Correct the path using:
  ```bash
  which python3
  ```
  Update `ExecStart` in the unit file to use `/usr/bin/python3`.

#### Debugging Steps:

1. Check service status:
   ```bash
   sudo systemctl status myapp.service
   ```
2. Check logs:
   ```bash
   sudo journalctl -u myapp.service
   ```
3. Test manually by running the command in `ExecStart`.

### **Scenario 2: Kubernetes Deployment Debugging**

#### Issue:

- Pod not starting due to image pull error.

#### Resolution:

- Verify the image tag is correct and the image exists.
- Push the image to a public Docker Hub repository if running Kubernetes locally. For example:
  ```bash
  docker tag python-systemd-app:latest <your-dockerhub-username>/python-systemd-app:latest
  docker push <your-dockerhub-username>/python-systemd-app:latest
  ```
  Update the `image` field in `deployment.yaml`:
  ```yaml
  image: <your-dockerhub-username>/python-systemd-app:latest
  ```
- Reapply the Deployment:
  ```bash
  kubectl apply -f deployment.yaml
  ```

#### Issue:

- LoadBalancer Service remains in "Pending" state due to lack of external LoadBalancer support.

#### Resolution:

- Change the service type to `NodePort` to expose the service on a specific port:

  Update `service.yaml`:

  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: python-app-service
  spec:
    selector:
      app: python-app
    ports:
      - protocol: TCP
        port: 80
        targetPort: 8080
        nodePort: 30007
    type: NodePort
  ```

- Reapply the updated service:
  ```bash
  kubectl apply -f service.yaml
  ```

- Get the node IP address and access the application:
  ```bash
  kubectl get nodes -o wide
  ```
  Use `http://<node-ip>:30007` to access the service.

#### Debugging Steps:

1. Describe the pod:
   ```bash
   kubectl describe pod <pod-name>
   ```
2. Check pod logs:
   ```bash
   kubectl logs <pod-name>
   ```
3. Exec into the pod for further inspection:
   ```bash
   kubectl exec -it <pod-name> -- /bin/bash
   ```

---

**Note**: Please replace the file paths with the paths on your own computer.

---

**Note**: If you encounter any issues, please feel free to contact me.

---
