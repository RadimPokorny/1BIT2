<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get and sanitize the data from the form
    $firstName = htmlspecialchars($_POST['first-name']);
    $lastName = htmlspecialchars($_POST['last-name']);
    $email = htmlspecialchars($_POST['email']);
    $companyName = htmlspecialchars($_POST['company-name']);
    $message = htmlspecialchars($_POST['message']);

    $to = "xpokorr00@fit.vutbr.cz"; // My mail
    $subject = "Nová zpráva z formuláře";
    $body = "Jméno: $firstName $lastName\n";
    $body .= "Email: $email\n";
    $body .= "Společnost: $companyName\n\n";
    $body .= "Zpráva:\n$message\n";

    $headers = "From: $email" . "\r\n" .
               "Reply-To: $email" . "\r\n" .
               "X-Mailer: PHP/" . phpversion();

    // Send a mail
    mail($to, $subject, $body, $headers);
}

// Go back to the index (relative path)
header("Location: ../index.html");
exit;
?>