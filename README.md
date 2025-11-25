# NotesApp Project

> Three-tier Notes application (Nginx frontend, Flask API, PostgreSQL) fully automated with **Ansible + Terraform** and deployed to a local **Minikube** cluster (MetalLB + NGINX Ingress).  
> A single playbook provisions all tooling on a fresh Ubuntu VM and exposes the app at `http://notes.<minikube-ip>.nip.io`.

![](docs/screenshots/frontend.png)

---

## 🧱 Architecture

| Layer | Description | Container |
|-------|-------------|-----------|
| Frontend | Glassmorphism UI served by Nginx, calls `/api/*`. | `notes-frontend` |
| API | Flask REST API exposing `/notes`, `/add`, `/delete`. | `notes-api` |
| Database | PostgreSQL 13 + persistent volume claim. | `notes-db` |

Infrastructure pieces installed/configured by Ansible:

- Docker Engine & Minikube
- kubectl, Helm, Terraform
- MetalLB (LoadBalancer IP pool) and NGINX Ingress
- Terraform apply (Deployments, Services, Ingress, PVC)

---

## 📦 Repository Layout

```
app/
 ├── Front-End/        # Static UI + Dockerfile (Nginx)
 ├── Back-end/         # Flask API + Dockerfile
 └── db/               # Postgres init SQL
terraform/             # K8s manifests managed via Terraform
ansible/               # site.yml + inventory (full automation)
README.md
```

---

## ✅ Prerequisites (control machine)

- Ubuntu 22.04 (VM or bare metal) with sudo access
- Git, Ansible (`sudo apt install ansible`)
- At least 4 vCPUs / 8 GB RAM available for Minikube

> Windows users: run the playbook from WSL2 Ubuntu or from a remote Linux VM. The automation expects an Ubuntu target.

---

## 🚀 One-Command Installation (Ansible)

```bash
git clone https://github.com/ilyaslog/notesapp-project.git
cd notesapp-project/ansible

# inventory already targets localhost; adjust if provisioning a remote VM.
LC_ALL=C ansible-playbook -i inventory site.yml --ask-become-pass
```

What this does:

1. Installs Docker, kubectl, Minikube, Terraform, Helm.
2. Starts Minikube and enables MetalLB + Ingress.
3. Builds/pulls the application images.
4. Runs `terraform apply` to create the namespace, Deployments, Services, PVC, and Ingress.
5. Prints the public URL: `http://notes.<minikube-ip>.nip.io`.

Keep a separate terminal open with:

```bash
minikube tunnel
```

This exposes the MetalLB LoadBalancer IP to your host.

---

## 🗄️ Initialize the Notes table (first run)

The API expects a `notes` table. Run once:

```bash
kubectl exec -it $(kubectl get pod -l app=notes-db -o jsonpath="{.items[0].metadata.name}") \
  -- psql -U postgres -d notesdb \
  -c "CREATE TABLE IF NOT EXISTS notes (id SERIAL PRIMARY KEY, content TEXT NOT NULL);"
```

---

## 🔍 Verifying the Deployment

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

Ingress should display:

```
NAME            CLASS HOSTS                       ADDRESS        PORTS
notes-ingress   nginx notes.<minikube-ip>.nip.io  192.168.49.2   80
```

Open the app:

```
http://notes.<minikube-ip>.nip.io
```

> If you are on Windows and the nip.io host is unreachable, forward the ingress controller locally:
> ```
> kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8095:80
> ```
> Add `127.0.0.1 notes.<minikube-ip>.nip.io` to `C:\Windows\System32\drivers\etc\hosts`, then browse to `http://notes.<minikube-ip>.nip.io:8095`.

You can also test individual services:

```bash
kubectl port-forward svc/notes-frontend 8080:80
kubectl port-forward svc/notes-api 5000:5000
curl http://localhost:5000/notes
```

---

## 🔁 Redeploying after code changes

1. Build the image inside Minikube:
   ```bash
   minikube image build -t notes-frontend:ui-revamp app/Front-End
   minikube image build -t notes-api:latest app/Back-end
   ```
2. Update `terraform/frontend.tf` or `backend.tf` with the new tags if needed.
3. Apply:
   ```bash
   cd terraform
   terraform apply -var="vm_ip=<minikube-ip>" -auto-approve
   ```
   or restart the specific deployment:
   ```bash
   kubectl rollout restart deploy/notes-frontend
   ```

---

## 🛠 Troubleshooting

| Symptom | Fix |
|---------|-----|
| `kubectl get ingress` shows `<pending>` | Ensure `minikube tunnel` is running and MetalLB addon is enabled. |
| nip.io URL unreachable on Windows | Add static route for `192.168.49.2` or use ingress port-forward + hosts entry as described above. |
| API returns `relation "notes" does not exist` | Run the `CREATE TABLE` command once (see section above). |
| `ImagePullBackOff` after rebuilding frontend/backend | Rebuild using `minikube image build ...` and restart the deployment. |

---

## 📸 Deliverables Checklist

- ✅ Working Ansible playbook (`ansible/site.yml`)
- ✅ Terraform IaC (`terraform/*.tf`)
- ✅ Application source (frontend, backend, db)
- ✅ Screenshot proving UI reachable via ingress (`docs/screenshots/frontend.png`)
- ✅ README (this file)

Enjoy hacking on NotesApp! PRs and improvements welcome.
