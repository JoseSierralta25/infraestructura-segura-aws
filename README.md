# Infraestructura Segura en AWS con Terraform

Este proyecto demuestra la implementación de una base de datos MySQL en AWS siguiendo las mejores prácticas de ciberseguridad.

## 🛡️ Medidas de Seguridad Implementadas
- **Acceso Privado:** La base de datos no tiene IP pública, evitando ataques directos desde internet.
- **Cifrado en Reposo:** Activación de cifrado AES-256 para proteger los datos almacenados.
- **Gestión de Secretos:** Uso de archivos `.tfvars` protegidos por `.gitignore` para no exponer contraseñas.
- **Principio de Menor Privilegio:** Configuración de Security Groups específicos para permitir solo el tráfico necesario.
