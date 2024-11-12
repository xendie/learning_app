let siteUrl

if (window.location.hostname === "localhost") {
    siteUrl = "http://localhost:5000"; // Development URL
} else {
    siteUrl = "https://it.damiangaworski.eu"; // Production URL
}