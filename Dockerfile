FROM registry.access.redhat.com/ubi8

# Handle prereqs
RUN INSTALL_PKGS="python39 python39-setuptools python39-pip \
        gnupg2 httpd-tools git openssh-clients" && \
    dnf -y --setopt=tsflags=nodocs update && \
    dnf -y --setopt=tsflags=nodocs install ${INSTALL_PKGS} && \
    dnf -y clean all --enablerepo='*' && \
    ln -sf "$(which python3)" /usr/libexec/platform-python

COPY requirements.txt /app/requirements.txt
RUN pip3 install --upgrade --no-cache-dir pip setuptools wheel && \
    pip3 install --upgrade --no-cache-dir -r /app/requirements.txt

RUN curl -sL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | \
    tar xvzf - -C /usr/local/bin

# Handle requirements
WORKDIR /app
COPY requirements.yml /app/requirements.yml
RUN ansible-galaxy collection install -r requirements.yml

COPY ansible.cfg /app/ansible.cfg
COPY inventory /app/inventory
COPY playbooks /app/playbooks
COPY roles /app/roles

VOLUME /app/var
VOLUME /app/tmp

# You should bind-mount your own tmp and vars dirs for playbook persistence.

ENTRYPOINT ["ansible-playbook"]
CMD ["--help"]
