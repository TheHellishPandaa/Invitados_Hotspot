<?php
// === CONFIGURACIÓN DE USUARIOS ===
// Aquí podrías usar una base de datos, LDAP, o un array simple
$users = [
    "invitado" => "wifi2025"
];

// === RECOGER VARIABLES ===
$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';
$tok      = $_POST['tok'] ?? '';
$redir    = $_POST['redir'] ?? 'http://example.com';

// === VALIDACIÓN DE CREDENCIALES ===
if (isset($users[$username]) && $users[$username] === $password) {
    // ✅ Credenciales correctas → reenviar a Nodogsplash
    $authaction = $_SERVER['NDS_AUTH_ACTION'] ?? $_GET['authaction'] ?? null;

    if (!$authaction) {
        die("Error: Falta authaction.");
    }

    // Redirigir al authaction de Nodogsplash con tok y redir
    header("Location: {$authaction}?tok={$tok}&redir=" . urlencode($redir));
    exit;
} else {
    // ❌ Credenciales incorrectas
    echo "<h2>Acceso denegado</h2>";
    echo "<p>Usuario o contraseña incorrectos.</p>";
    echo "<a href=\"splash.html\">Volver</a>";
}
?>
