<#import "template.ftl" as layout>

<@layout.registrationLayout displayMessage=!messagesPerField.existsError('emailCode'); section>
  <#if section="header">
    ${msg("doLogIn")}
  <#elseif section="form">
    <form id="kc-otp-login-form" class="mt-3" action="${url.loginAction}" method="post">
      <div class="mb-3">
        <label for="emailCode" class="form-label">${msg("emailOtpForm")}</label>

        <input id="emailCode" name="emailCode" autocomplete="off" type="text" class="form-control <#if messagesPerField.existsError('emailCode')>is-invalid</#if>" autofocus aria-invalid="<#if messagesPerField.existsError('emailCode')>true</#if>" placeholder="XXXXXX" inputmode="numeric">

        <#if messagesPerField.existsError('emailCode')>
          <div id="input-error-otp-code" class="invalid-feedback" aria-live="polite">
            ${kcSanitize(messagesPerField.get('emailCode'))?no_esc}
          </div>
        </#if>
      </div>

      <div class="hstack gap-2">
        <input class="btn btn-primary" name="login" type="submit" value="${msg("doLogIn")}">
        <input class="btn btn-secondary" name="resend" type="submit" value="${msg("resendCode")}">
        <input class="btn btn-secondary" name="cancel" type="submit" value="${msg("doCancel")}">
      </div>
    </form>
  </#if>
</@layout.registrationLayout>
