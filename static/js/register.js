function validateForm() {
    // reset error messages
    document.getElementById('password-error').innerText = ''
    document.getElementById('email-error').innerText = ''

    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirm_password').value;
    const email = document.getElementById('email').value
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    let response = true
    if (password !== confirmPassword) {
        document.getElementById('password-error').innerText = 'Passwords must match!';
        response = false;  // Prevent form submission
    }
    // validate e-mail
    if (!emailPattern.test(email)){
        document.getElementById('email-error').innerText = 'Enter a proper e-mail address!';
        response = false;
    }
    if (response === true){
        return true;    
    } else {
        return false;
    // Allow form submission
    }
}