ARG BASE_USER
ARG MAINTAINER
FROM debian:testing
MAINTAINER UNBUTTONED

# Install Packages (basic tools, cups, basic drivers, HP drivers)
RUN curl -skL http://www.bchemnet.com/suldr/pool/debian/extra/su/suldr-keyring_2_all.deb -o /tmp/suldr-keyring.deb
RUN dpkg -i /tmp/suldr-keyring.deb
RUN add-apt-repository "deb http://www.bchemnet.com/suldr/ debian extra"
RUN apt-get update \
&& apt-get install -y \
  sudo \
  whois \
  cups \
  cups-client \
  cups-bsd \
  cups-filters \
  foomatic-db-compressed-ppds \
  printer-driver-all \
  openprinting-ppds \
  hpijs-ppds \
  hp-ppd \
  hplip \
  smbclient \
  suld-driver-4.01.17 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Add user and disable sudo password checking
RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
&& sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

# Configure the service's to be reachable
RUN /usr/sbin/cupsd \
  && while [ ! -f /var/run/cups/cupsd.pid ]; do sleep 1; done \
  && cupsctl --remote-admin --remote-any --share-printers \
  && kill $(cat /var/run/cups/cupsd.pid)

# Default shell
CMD ["/usr/sbin/cupsd", "-f"]
