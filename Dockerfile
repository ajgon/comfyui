# ComfyUI Docker Build File by John Aldred
# https://www.johnaldred.com
# https://github.com/kaouthia

# Use a minimal Python base image (adjust version as needed)
FROM python:3.12-slim-bookworm

# Allow passing in your host UID/GID (defaults 1000:1000)
ARG UID=1000
ARG GID=1000

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      cmake \
      fontconfig \
      fonts-dejavu-core \
      git \
      libgl1 \
      libglib2.0-0 \
      libglx-mesa0 \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd --gid ${GID} appuser \
 && useradd --uid ${UID} --gid ${GID} --create-home --shell /bin/bash appuser \
 && mkdir -p /app \
 && git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI \
 && sh -c 'cd /app/ComfyUI && pip install --no-cache-dir -r requirements.txt && pip cache purge' \
 && chown -R "$UID:$GID" /usr/local /app

# Switch to non-root user
USER $UID:$GID
ENV PATH=/home/appuser/.local/bin:$PATH
WORKDIR /app/ComfyUI

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
EXPOSE 8188
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python","/app/ComfyUI/main.py","--listen","0.0.0.0"]
