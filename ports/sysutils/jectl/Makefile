PORTNAME=	jectl
PORTVERSION=	0.1
CATEGORIES=	sysutils

MAINTAINER=	rob.wing@klarasystems.com
COMMENT=	The nexus between poudriere and jail.conf
WWW=		https://github.com/KlaraSystems/jectl

LICENSE=	BSD2CLAUSE

USE_GITHUB=	yes
GH_ACCOUNT=	jlduran
GH_TAGNAME=	3a10a1a

WRKSRC=		${WRKDIR}/

PLIST_FILES=	sbin/${PORTNAME}

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/sbin/${PORTNAME} ${STAGEDIR}${PREFIX}/sbin/${PORTNAME}

.include <bsd.port.mk>
