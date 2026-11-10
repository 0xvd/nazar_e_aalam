from __future__ import annotations

import smtplib
from datetime import datetime
from email.message import EmailMessage
from email.utils import formataddr
from pathlib import Path

from config import ENV
from jinja2 import Environment, FileSystemLoader, select_autoescape

_TEMPLATES_DIR = Path(__file__).resolve().parent / "templates"
_tpl_env = Environment(
    loader=FileSystemLoader(_TEMPLATES_DIR),
    autoescape=select_autoescape(["html"]),
)
_tpl_env.globals["year"] = datetime.now().year


def render_template(name: str, **ctx) -> str:
    """Render a template from services/templates/ with autoescaping."""
    return _tpl_env.get_template(name).render(**ctx)


def send_email(
    *,
    to: str,
    subject: str,
    html_body: str,
    text_body: str | None = None,
) -> None:
    """
    Send one email via SMTP.

    Raises:
        RuntimeError: SMTP not configured.
        smtplib.SMTPAuthenticationError: bad credentials.
        smtplib.SMTPException: any other SMTP failure.
    """
    if not (ENV.SMTP_HOST and ENV.SMTP_USER and ENV.SMTP_PASSWORD):
        raise RuntimeError(
            "SMTP is not configured. Set SMTP_HOST, SMTP_USER, "
            "SMTP_PASSWORD, SMTP_FROM in .env"
        )

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = formataddr((ENV.SMTP_FROM_NAME, ENV.SMTP_FROM or ENV.SMTP_USER))
    msg["To"] = to
    msg.set_content(text_body or "This email requires an HTML-capable client.")
    msg.add_alternative(html_body, subtype="html")

    if ENV.SMTP_PORT == 465:
        with smtplib.SMTP_SSL(ENV.SMTP_HOST, ENV.SMTP_PORT, timeout=20) as smtp:
            smtp.login(ENV.SMTP_USER, ENV.SMTP_PASSWORD)
            smtp.send_message(msg)
    else:
        with smtplib.SMTP(ENV.SMTP_HOST, ENV.SMTP_PORT, timeout=20) as smtp:
            if ENV.SMTP_TLS:
                smtp.starttls()
            smtp.login(ENV.SMTP_USER, ENV.SMTP_PASSWORD)
            smtp.send_message(msg)
