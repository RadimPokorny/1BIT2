<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Načtení dat
    $firstName = htmlspecialchars($_POST['first-name']);
    $lastName = htmlspecialchars($_POST['last-name']);
    $email = htmlspecialchars($_POST['email']);
    $companyName = htmlspecialchars($_POST['company-name']);
    $message = htmlspecialchars($_POST['message']);

    $to = "xpokorr00@fit.vutbr.cz"; // Muj mail
    $subject = "Nová zpráva z formuláře";
    $body = "Jméno: $firstName $lastName\n";
    $body .= "Email: $email\n";
    $body .= "Společnost: $companyName\n\n";
    $body .= "Zpráva:\n$message\n";

    $headers = "From: $email" . "\r\n" .
               "Reply-To: $email" . "\r\n" .
               "X-Mailer: PHP/" . phpversion();

    // Odeslání emailu
    mail($to, $subject, $body, $headers);
}

// Přesměrování zpátky na index.php
header("Location: ../index.html");
exit;
?>