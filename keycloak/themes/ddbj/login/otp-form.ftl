<#import "template.ftl" as layout>

<@layout.registrationLayout displayInfo=true; section>
  <#if section = "title">
    ${msg("doLogIn")}
  <#elseif section = "header">
    <div id="kc-username" class="${properties.kcFormGroupClass!}">
      <label id="kc-attempted-username">${auth.attemptedUsername}</label>

      <a id="reset-login" href="${url.loginRestartFlowUrl}" aria-label="${msg("restartLoginTooltip")}">
        ${msg("restartLoginTooltip")}
      </a>
    </div>
  <#elseif section = "form">
    <form id="kc-otp-login-form" action="${url.loginAction}" method="post">
      <div class="mb-3">
        <label for="otp" class="form-label">Please enter the six digit code that was delivered to your email.</label>

        <input id="otp" name="otp" autocomplete="off" type="text" class="form-control <#if messagesPerField.existsError('totp')>is-invalid</#if>" autofocus aria-invalid="<#if messagesPerField.existsError('totp')>true</#if>" placeholder="XXXXXX" inputmode="numeric">

        <#if messagesPerField.existsError('totp')>
          <div id="input-error-otp-code" class="invalid-feedback" aria-live="polite">
            ${kcSanitize(messagesPerField.get('totp'))?no_esc}
          </div>
        </#if>
      </div>

      <div id="kc-form-buttons" class="hstack gap-2">
        <input class="btn btn-primary" name="submit" id="kc-submit" type="submit" value="${msg("doSubmit")}" />
        <input class="btn btn-secondary" name="resend" id="kc-resend" type="submit" value="${msg("doResend")}" />
      </div>
    </form>
  </#if>
</@layout.registrationLayout>
