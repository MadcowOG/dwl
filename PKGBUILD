# Maintainer: Me
pkgname=dwl
pkgver=1.0.0
pkgrel=1
pkgdesc="dwm for wayland"
arch=('any')
url="https://github.com/djpohly/dwl"
license=('MIT')
source=('dwl-0.4.tar.gz')

depends=(
        'bemenu'
        'alacritty'
        'clipman'
        'wl-clipboard'
        'lxsession-gtk3'
        )

optdepends=(
        'pasystray: For audio control in systray'
        'network-manager-applet: For internet control in systray'
        'dunst: For notifications'
        )

makedepends=('make')

sha512sums=('SKIP')

package() {
    cd "$srcdir/dwl-0.4"
    sudo make clean install
}
