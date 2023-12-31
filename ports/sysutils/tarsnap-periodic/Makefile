PORTNAME=	tarsnap-periodic
PORTVERSION=	1.0.20170413
CATEGORIES=	sysutils

MAINTAINER=	kamila@ksp.sk
COMMENT=	Simple way of making tarsnap backups using the periodic system
WWW=		https://github.com/Labtec/tarsnap-periodic

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

RUN_DEPENDS=	tarsnap:sysutils/tarsnap

USE_GITHUB=	yes
GH_ACCOUNT=	Labtec
GH_TAGNAME=	4803315

NO_ARCH=	yes
NO_BUILD=	yes

PERIODIC_DIRS=	etc/periodic/daily etc/periodic/weekly \
		etc/periodic/monthly etc/periodic

PERIODIC_FILES=	etc/periodic/daily/900.tarsnap-backup \
		etc/periodic/weekly/900.tarsnap-backup \
		etc/periodic/monthly/900.tarsnap-backup

SCRIPT_FILE=	bin/tarsnap-backup

PLIST_FILES=	${PERIODIC_FILES} ${SCRIPT_FILE}

post-patch:
	@${REINPLACE_CMD} -e "s|TARSNAP_CMD=.*|TARSNAP_CMD=${PREFIX}/bin/tarsnap|" \
		${WRKSRC}/${SCRIPT_FILE}
.for _file in ${PERIODIC_FILES}
	@${REINPLACE_CMD} -e "s|tarsnap-backup|${PREFIX}/bin/tarsnap-backup|" \
		${WRKSRC}/${_file}
.endfor

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/bin/tarsnap-backup ${STAGEDIR}${PREFIX}/bin
.for _dir in ${PERIODIC_DIRS}
	@${MKDIR} ${STAGEDIR}${PREFIX}/${_dir}
.endfor

.for _file in ${PERIODIC_FILES}
	${INSTALL_SCRIPT} ${WRKSRC}/${_file} ${STAGEDIR}${PREFIX}/${_file}
.endfor

.include <bsd.port.mk>
