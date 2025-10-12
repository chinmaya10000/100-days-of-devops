# Nautilus DevOps - Dockerfile Fix (App Server 2)

## Task Overview
The Nautilus DevOps team required a working Dockerfile to build a custom Apache HTTPD image with SSL enabled and listening on port 8080.  
The original Dockerfile had incorrect file paths and improper copy commands, which caused the image build to fail.

---

## Fixes Implemented

1. **Corrected Apache configuration file paths**
   - The correct location inside the `httpd` container is `/usr/local/apache2/conf/httpd.conf`.
   - Updated all `sed` commands accordingly.

2. **Replaced `RUN cp` with `COPY`**
   - The `certs` and `html` directories exist in the build context, so `COPY` must be used instead of `RUN cp`.

3. **Verified SSL configuration**
   - Ensured that the `ssl_module` and `socache_shmcb_module` lines are uncommented.
   - Ensured `Include conf/extra/httpd-ssl.conf` is active.

4. **Set HTTP port to 8080**
   - Updated `Listen 80` to `Listen 8080` in the Apache configuration.

---

## Final Dockerfile

```dockerfile
FROM httpd:2.4.43

RUN sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/httpd.conf

RUN sed -i '/LoadModule\ ssl_module modules\/mod_ssl.so/s/^#//g' /usr/local/apache2/conf/httpd.conf

RUN sed -i '/LoadModule\ socache_shmcb_module modules\/mod_socache_shmcb.so/s/^#//g' /usr/local/apache2/conf/httpd.conf

RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' /usr/local/apache2/conf/httpd.conf

COPY certs/server.crt /usr/local/apache2/conf/server.crt
COPY certs/server.key /usr/local/apache2/conf/server.key
COPY html/index.html /usr/local/apache2/htdocs/
