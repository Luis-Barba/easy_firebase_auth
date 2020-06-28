import 'package:flutter/material.dart';

class AuthStrings {
  // Sign In Buttons
  String signInWithEmail, signInWithGoogle, signInWithTwitter, signInWithFacebook, signInAnonymous;

  // Other Buttons
  String understood, changePassword, cancel, accept, next, forgotPassword;

  // Notices
  String weWillSendYouAnEmailToChangePassword, emailSentToChangePassword;

  // Markdown
  String emailRegisteredEnterPasswordNoticeMarkdown, privacyMarkdown;

  // Errors
  String errorWeakPassword,
      errorInvalidEmail,
      errorEmailAlreadyInUse,
      errorWrongPassword,
      errorUserNotFound,
      errorUserDisabled,
      errorTooManyRequests,
      errorOperationNotAllowed,
      emailNotValid,
      emailCantBeEmpty,
      nameCantBeEmpty,
      passwordTooShort;

  String email, passwordHint, passwordEmpty, nameHint, loginAppBarTitle;

  AuthStrings({
    @required this.signInWithEmail,
    @required this.signInWithGoogle,
    @required this.signInWithFacebook,
    @required this.signInWithTwitter,
    @required this.signInAnonymous,
    @required this.understood,
    @required this.changePassword,
    @required this.cancel,
    @required this.accept,
    @required this.next,
    @required this.forgotPassword,
    @required this.weWillSendYouAnEmailToChangePassword,
    @required this.emailSentToChangePassword,
    @required this.emailRegisteredEnterPasswordNoticeMarkdown,
    @required this.privacyMarkdown,
    @required this.errorWeakPassword,
    @required this.errorInvalidEmail,
    @required this.errorEmailAlreadyInUse,
    @required this.errorWrongPassword,
    @required this.errorUserNotFound,
    @required this.errorUserDisabled,
    @required this.errorTooManyRequests,
    @required this.errorOperationNotAllowed,
    @required this.emailNotValid,
    @required this.emailCantBeEmpty,
    @required this.nameCantBeEmpty,
    @required this.passwordTooShort,
    @required this.email,
    @required this.passwordHint,
    @required this.passwordEmpty,
    @required this.nameHint,
    @required this.loginAppBarTitle,
  });

  factory AuthStrings.spanish(
      {signInWithEmail = "Acceder con email",
      signInWithGoogle = "Acceder con Google",
      signInWithFacebook = "Acceder con Facebook",
      signInWithTwitter = "Acceder con Twitter",
      signInAnonymous = "Continuar sin registrarme",
      understood = "Ok",
      changePassword = "Cambiar contraseña",
      cancel = "Cancelar",
      accept = "Aceptar",
      next = "SIGUIENTE",
      forgotPassword = "¿Olvidaste la contraseña?",
      weWillSendYouAnEmailToChangePassword =
          "Te enviaremos un email a \$ con instrucciones sobre como cambiar la contraseña",
      emailSentToChangePassword = 'Te hemos enviado un emai a \$',
      emailRegisteredEnterPasswordNoticeMarkdown =
          "## ¡Hola de nuevo!\nYa has usado __\$__ para iniciar sesión. Introduce la contraseña de esta cuenta.",
      privacyMarkdown =
          "Acepto la política de privacidad y los términos de uso",
      errorWeakPassword = 'La contraseña no es segura',
      errorInvalidEmail = 'Email no válido',
      errorEmailAlreadyInUse = 'Ese email ya está en uso',
      errorWrongPassword = 'Contraseña errónea',
      errorUserNotFound = 'Usuario no encontrado',
      errorUserDisabled = 'Usuario inhabilitado',
      errorTooManyRequests =
          'Has hecho demasiadas peticiones, intentalo más tarde',
      errorOperationNotAllowed = 'Operación no permitida',
      emailNotValid = 'Email no válido',
      emailCantBeEmpty = 'El email no puede estar vacío',
      nameCantBeEmpty = 'El nombre no puede estar vacío',
      passwordTooShort = "La contraseña es demasiado corta",
      email = "Correo electrónico",
      passwordHint = 'Contraseña',
      passwordEmpty = 'Introduce una contraseña',
      nameHint = 'Nombre',
      loginAppBarTitle = "Login"}) {
    return AuthStrings(
      signInWithEmail: signInWithEmail,
      signInWithGoogle: signInWithGoogle,
      signInWithFacebook: signInWithFacebook,
      signInWithTwitter: signInWithTwitter,
      signInAnonymous: signInAnonymous,
      understood: understood,
      changePassword: changePassword,
      cancel: cancel,
      accept: accept,
      next: next,
      forgotPassword: forgotPassword,
      weWillSendYouAnEmailToChangePassword:
          weWillSendYouAnEmailToChangePassword,
      emailSentToChangePassword: emailSentToChangePassword,
      emailRegisteredEnterPasswordNoticeMarkdown:
          emailRegisteredEnterPasswordNoticeMarkdown,
      privacyMarkdown: privacyMarkdown,
      errorWeakPassword: errorWeakPassword,
      errorInvalidEmail: errorInvalidEmail,
      errorEmailAlreadyInUse: errorEmailAlreadyInUse,
      errorWrongPassword: errorWrongPassword,
      errorUserNotFound: errorUserNotFound,
      errorUserDisabled: errorUserDisabled,
      errorTooManyRequests: errorTooManyRequests,
      errorOperationNotAllowed: errorOperationNotAllowed,
      emailNotValid: emailNotValid,
      emailCantBeEmpty: emailCantBeEmpty,
      nameCantBeEmpty: nameCantBeEmpty,
      passwordTooShort: passwordTooShort,
      email: email,
      passwordHint: passwordHint,
      passwordEmpty: passwordEmpty,
      nameHint: nameHint,
      loginAppBarTitle: loginAppBarTitle,
    );
  }


  factory AuthStrings.portuguese(
      {
        signInWithEmail = "Continuar com email",
        signInWithGoogle = "Continuar com Google",
        signInWithFacebook = "Continuar com Facebook",
        signInWithTwitter = "Continuar com Twitter",
        signInAnonymous = "Continuar sem registar",
        understood = "Ok",
        changePassword = "Alterar palavra-passe",
        cancel = "Cancelar",
        accept = "Aceitar",
        next = "SEGUINTE",
        forgotPassword = "Esqueceu-se da palavra-passe?",
        weWillSendYouAnEmailToChangePassword =
        "Enviaremos um email a \$ com instruções sobre como alterar a palavra-passe",
        emailSentToChangePassword = 'Enviámos um email a \$',
        emailRegisteredEnterPasswordNoticeMarkdown =
        "Já utilizou anteriormente o email __\$__ para iniciar a sessão. Introduza a palavra-passe para esta conta",
        privacyMarkdown =
        "Aceito a política de privacidade e os termos de utilização",
        errorWeakPassword = 'A palavra-passe não é segura',
        errorInvalidEmail = 'Email inválido',
        errorEmailAlreadyInUse = 'Esse email já está em utilização',
        errorWrongPassword = 'Palavra-passe incorreta',
        errorUserNotFound = 'Utilizador não encontrado',
        errorUserDisabled = 'Utilizador desativado',
        errorTooManyRequests =
        'Fez demasiadas tentativas, tente mais tarde.',
        errorOperationNotAllowed = 'Operação não permitida',
        emailNotValid = 'Email inválido',
        emailCantBeEmpty = 'O email não pode estar vazio',
        nameCantBeEmpty = 'O nombre não pode estar vazio',
        passwordTooShort = "A palavra-passe é demasiado curta",
        email = "EMail",
        passwordHint = 'Palavra-passe',
        passwordEmpty = 'Introduza uma palavra-passe',
        nameHint = 'Nome',
        loginAppBarTitle = "Iniciar Sessão"}) {
    return AuthStrings(
      signInWithEmail: signInWithEmail,
      signInWithGoogle: signInWithGoogle,
      signInWithFacebook: signInWithFacebook,
      signInWithTwitter: signInWithTwitter,
      signInAnonymous: signInAnonymous,
      understood: understood,
      changePassword: changePassword,
      cancel: cancel,
      accept: accept,
      next: next,
      forgotPassword: forgotPassword,
      weWillSendYouAnEmailToChangePassword:
      weWillSendYouAnEmailToChangePassword,
      emailSentToChangePassword: emailSentToChangePassword,
      emailRegisteredEnterPasswordNoticeMarkdown:
      emailRegisteredEnterPasswordNoticeMarkdown,
      privacyMarkdown: privacyMarkdown,
      errorWeakPassword: errorWeakPassword,
      errorInvalidEmail: errorInvalidEmail,
      errorEmailAlreadyInUse: errorEmailAlreadyInUse,
      errorWrongPassword: errorWrongPassword,
      errorUserNotFound: errorUserNotFound,
      errorUserDisabled: errorUserDisabled,
      errorTooManyRequests: errorTooManyRequests,
      errorOperationNotAllowed: errorOperationNotAllowed,
      emailNotValid: emailNotValid,
      emailCantBeEmpty: emailCantBeEmpty,
      nameCantBeEmpty: nameCantBeEmpty,
      passwordTooShort: passwordTooShort,
      email: email,
      passwordHint: passwordHint,
      passwordEmpty: passwordEmpty,
      nameHint: nameHint,
      loginAppBarTitle: loginAppBarTitle,
    );
  }

  factory AuthStrings.english(
      {signInWithEmail = "Sign in with email",
      signInWithGoogle = "Sign in with Google",
      signInWithFacebook = "Sign in with Facebook",
      signInWithTwitter = "Sign in with Twitter",
      signInAnonymous = "Continue without registering",
      understood = "Ok",
      changePassword = "Change password",
      cancel = "Cancel",
      accept = "Acept",
      next = "NEXT",
      forgotPassword = "¿Forgot password?",
      weWillSendYouAnEmailToChangePassword =
          "We will send you an email to \$ with instructions on how to change the password",
      emailSentToChangePassword = 'We have sent you an emai to \$',
      emailRegisteredEnterPasswordNoticeMarkdown =
          "## Hello again! \n You have already used __\$__ to log in. Enter the password for this account.",
      privacyMarkdown = "I accept the privacy policy and the terms of use",
      errorWeakPassword = 'The password is not secure',
      errorInvalidEmail = 'Invalid email',
      errorEmailAlreadyInUse = 'That email is already in use',
      errorWrongPassword = 'Wrong password',
      errorUserNotFound = 'User not found',
      errorUserDisabled = 'Disabled user',
      errorTooManyRequests =
          'You made too many requests, please try again later',
      errorOperationNotAllowed = 'Operation not allowed',
      emailNotValid = 'Invalid email',
      emailCantBeEmpty = 'Email cannot be empty',
      nameCantBeEmpty = 'The name cannot be empty',
      passwordTooShort = "The password is too short",
      email = "Email",
      passwordHint = 'Password',
      passwordEmpty = 'Enter a password',
      nameHint = 'Name',
      loginAppBarTitle = "Login"}) {
    return AuthStrings(
      signInWithEmail: signInWithEmail,
      signInWithGoogle: signInWithGoogle,
      signInWithFacebook: signInWithFacebook,
      signInWithTwitter: signInWithTwitter,
      signInAnonymous: signInAnonymous,
      understood: understood,
      changePassword: changePassword,
      cancel: cancel,
      accept: accept,
      next: next,
      forgotPassword: forgotPassword,
      weWillSendYouAnEmailToChangePassword:
          weWillSendYouAnEmailToChangePassword,
      emailSentToChangePassword: emailSentToChangePassword,
      emailRegisteredEnterPasswordNoticeMarkdown:
          emailRegisteredEnterPasswordNoticeMarkdown,
      privacyMarkdown: privacyMarkdown,
      errorWeakPassword: errorWeakPassword,
      errorInvalidEmail: errorInvalidEmail,
      errorEmailAlreadyInUse: errorEmailAlreadyInUse,
      errorWrongPassword: errorWrongPassword,
      errorUserNotFound: errorUserNotFound,
      errorUserDisabled: errorUserDisabled,
      errorTooManyRequests: errorTooManyRequests,
      errorOperationNotAllowed: errorOperationNotAllowed,
      emailNotValid: emailNotValid,
      emailCantBeEmpty: emailCantBeEmpty,
      nameCantBeEmpty: nameCantBeEmpty,
      passwordTooShort: passwordTooShort,
      email: email,
      passwordHint: passwordHint,
      passwordEmpty: passwordEmpty,
      nameHint: nameHint,
      loginAppBarTitle: loginAppBarTitle,
    );
  }
}
