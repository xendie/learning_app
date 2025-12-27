let siteUrl
// URL used in AJAX requests
if (window.location.hostname === "localhost") {
    siteUrl = "http://localhost:5000"; // Development URL
} else {
    siteUrl = window.location.hostname; // Production URL
}

$(document).ready(function() {
    // Mobile menu used in base.html
    const $mobileMenu = $('#mobile-menu');
    const $navList = $('.navbar-items');

    $mobileMenu.on('click', function() {
        $navList.toggleClass('active'); // toggle hamburger button
    });
});