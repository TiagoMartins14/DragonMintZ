FROM ghcr.io/foundry-rs/foundry:stable

WORKDIR /home/DragonMintZ

COPY . .

USER root
RUN apt-get update && apt-get install -y curl gnupg \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN chmod +x start.sh
RUN chown -R foundry:foundry /home/DragonMintZ
RUN git config --global --add safe.directory /home/DragonMintZ

USER foundry

ENTRYPOINT ["/bin/sh", "/home/DragonMintZ/start.sh"]
