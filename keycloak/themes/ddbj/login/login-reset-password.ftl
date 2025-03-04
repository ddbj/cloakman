<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayMessage=!messagesPerField.existsError('username'); section>
  <#if section = "header">
    ${msg("emailForgotTitle")}
  <#elseif section = "form">
    <form id="kc-reset-password-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
      <div class="mb-3">
        <label for="username" class="form-label"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label>

        <input type="text" id="username" name="username" class="form-control <#if messagesPerField.existsError('username')>is-invalid</#if>" autofocus value="${(auth.attemptedUsername!'')}" aria-invalid="<#if messagesPerField.existsError('username')>true</#if>" required>

        <#if messagesPerField.existsError('username')>
          <div id="input-error-username" class="invalid-feedback" aria-live="polite">
            ${kcSanitize(messagesPerField.get('username'))?no_esc}
          </div>
        </#if>
      </div>

      <div class="mb-3">
        <a href="${url.loginUrl}">${kcSanitize(msg("backToLogin"))?no_esc}</a>
      </div>

      <div id="kc-form-buttons" class="d-grid">
        <input class="btn btn-primary" type="submit" value="${msg("doSubmit")}"/>
      </div>
    </form>
  <#elseif section = "info" >
    <div class="mt-3">
      <#if realm.duplicateEmailsAllowed>
        ${msg("emailInstructionUsername")}
      <#else>
        ${msg("emailInstruction")}
      </#if>
    </div>
  </#if>
</@layout.registrationLayout>
