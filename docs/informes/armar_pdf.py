"""Arma el PDF de docs/26 con la marca Huellamy. Uso, desde la raíz: python3 -I docs/informes/armar_pdf.py docs/26-lanzamiento-roles-etapas.md /tmp/informe.html "$PWD" y después google-chrome --headless=new --no-pdf-header-footer --allow-file-access-from-files --print-to-pdf=docs/informes/26-lanzamiento-roles-etapas.pdf file:///tmp/informe.html"""
import html, re, sys, pathlib

src, out, repo = map(pathlib.Path, sys.argv[1:4])
lines = src.read_text(encoding="utf-8").splitlines()


def inline(t):
    t = html.escape(t, quote=False)
    t = re.sub(r"`([^`]+)`", r"<code>\1</code>", t)
    t = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", t)
    t = re.sub(r"\[([^\]]+)\]\(([^) ]+)[^)]*\)", r'<a href="\2">\1</a>', t)
    return t


body, i = [], 0
title = ""
while i < len(lines):
    l = lines[i]
    if l.startswith("# "):
        title = l[2:].split("· ", 1)[-1]
        i += 1
        continue
    if l.startswith("> "):  # nota de cabecera: va en la portada
        i += 1
        continue
    if l.startswith("### "):
        body.append(f"<h3>{inline(l[4:])}</h3>")
    elif l.startswith("## "):
        body.append(f"<h2>{inline(l[3:])}</h2>")
    elif l.startswith("|"):
        rows = []
        while i < len(lines) and lines[i].startswith("|"):
            rows.append([c.strip() for c in lines[i].strip().strip("|").split("|")])
            i += 1
        head, data = rows[0], rows[2:]
        cls = {"Etapa": "plazos" if len(head) == 4 else "gastos", "Trámite": "tramites"}.get(head[0], "")
        if cls == "": cls = "matriz" if head[0] == "" else (("pasos cuatro" if len(head) == 4 else "pasos") if head[-1] == "Paso" else ("fechas" if head[0] == "Fecha" else ("roles" if head[0] == "Rol" else "")))
        h = "".join(f"<th>{inline(c)}</th>" for c in head)
        d = "".join("<tr>" + "".join(f"<td>{inline(c)}</td>" for c in r) + "</tr>" for r in data)
        body.append(f'<table class="{cls}"><thead><tr>{h}</tr></thead><tbody>{d}</tbody></table>')
        continue
    elif re.match(r"\d+\. ", l):
        items = []
        while i < len(lines) and re.match(r"\d+\. ", lines[i]):
            items.append(inline(lines[i].split(". ", 1)[1]))
            i += 1
        body.append("<ol>" + "".join(f"<li>{x}</li>" for x in items) + "</ol>")
        continue
    elif l.startswith("- "):
        items = []
        check = l.startswith("- [ ]")
        while i < len(lines) and lines[i].startswith("- "):
            items.append(inline(lines[i][6:] if check else lines[i][2:]))
            i += 1
        cls = ' class="check"' if check else ""
        body.append(f"<ul{cls}>" + "".join(f"<li>{x}</li>" for x in items) + "</ul>")
        continue
    elif l.strip():
        body.append(f"<p>{inline(l)}</p>")
    i += 1

fuentes = (repo / "admin/assets/fuentes").as_uri()
logo = (repo / "web-publica/assets/logo.png").as_uri()
doc = f"""<!doctype html><html lang="es"><head><meta charset="utf-8"><title>{html.escape(title)}</title>
<style>
@font-face{{font-family:Nunito;src:url({fuentes}/Nunito-ExtraBold.ttf);font-weight:800}}
@font-face{{font-family:Nunito;src:url({fuentes}/Nunito-Bold.ttf);font-weight:700}}
@font-face{{font-family:'Nunito Sans';src:url({fuentes}/NunitoSans-Regular.ttf);font-weight:400}}
@font-face{{font-family:'Nunito Sans';src:url({fuentes}/NunitoSans-Bold.ttf);font-weight:700}}
@page{{size:A4;margin:16mm 14mm 16mm 14mm}}
:root{{--azul:#0B4F94;--brillante:#1E88E5;--naranja:#E8923A;--noche:#0E1A26;--fondo:#F0F8FE}}
body{{font-family:'Nunito Sans',sans-serif;color:var(--noche);font-size:10pt;line-height:1.45;margin:0}}
.portada{{height:255mm;display:flex;flex-direction:column;justify-content:center;align-items:center;text-align:center;
  background:var(--fondo);border-radius:20px;page-break-after:always;padding:0 18mm}}
.portada img{{width:95mm;margin-bottom:12mm}}
.portada h1{{font-family:Nunito;font-weight:800;color:var(--azul);font-size:28pt;line-height:1.15;margin:0 0 6mm}}
.portada .sub{{font-size:12.5pt;max-width:140mm}}
.portada .meta{{margin-top:14mm;font-size:10pt;color:#3a4b5c}}
.portada .barra{{width:40mm;height:5px;background:var(--naranja);border-radius:3px;margin:8mm auto}}
h2{{font-family:Nunito;font-weight:800;color:var(--azul);font-size:16pt;margin:9mm 0 3mm;padding-bottom:2mm;
  border-bottom:3px solid var(--naranja);page-break-after:avoid}}
h3{{font-family:Nunito;font-weight:700;color:var(--brillante);font-size:12pt;margin:6mm 0 2mm;page-break-after:avoid}}
p{{margin:0 0 3mm}}
strong{{color:var(--azul)}}
code{{font-family:inherit;background:#E3EEF8;padding:0 3px;border-radius:4px;font-size:9pt}}
table{{width:100%;border-collapse:collapse;margin:2mm 0 4mm;font-size:9pt}}
thead{{display:table-header-group}}
tr{{page-break-inside:avoid}}
th{{background:var(--azul);color:#fff;text-align:left;padding:2mm 2.5mm;font-family:Nunito;font-weight:700}}
td{{padding:1.8mm 2.5mm;border-bottom:1px solid #D5E3F0;vertical-align:top}}
tbody tr:nth-child(even) td{{background:#F6FAFE}}
table{{table-layout:fixed}}
td,th{{overflow-wrap:anywhere;word-break:normal}}
code{{white-space:normal;overflow-wrap:anywhere}}
table.pasos th:last-child{{width:24mm}} table.pasos td:last-child{{color:#4a5d70}}
table.pasos th:first-child{{width:38mm}}
table.cuatro th:first-child{{width:70mm}} table.cuatro th:nth-child(3){{width:26mm}}
table.fechas th:first-child{{width:24mm}}
table.roles th:first-child{{width:40mm}} table.roles th:nth-child(2){{width:20mm}}
table.matriz th:first-child{{width:26mm}}
table.plazos th:first-child{{width:30mm}} table.plazos th:nth-child(2){{width:26mm}}
table.tramites th:first-child{{width:42mm}} table.tramites th:last-child{{width:32mm}}
table.gastos th:first-child{{width:24mm}} table.gastos th:last-child{{width:50mm}}
ol{{margin:0 0 3mm;padding-left:6mm}}
table.matriz td:first-child{{font-weight:700;color:var(--azul)}}
ul{{margin:0 0 3mm;padding-left:6mm}} li{{margin-bottom:1mm}}
ul.check{{list-style:none;padding-left:0}}
ul.check li{{padding-left:7mm;position:relative}}
ul.check li:before{{content:'';position:absolute;left:0;top:1.2mm;width:3.2mm;height:3.2mm;border:1.6px solid var(--naranja);border-radius:3px}}
</style></head><body>
<section class="portada"><img src="{logo}" alt="Huellamy">
<h1>{html.escape(title)}</h1><div class="barra"></div>
<p class="sub">Propuesta de reparto de tareas entre <strong>desarrollo y producto</strong> (Rodrigo) y <strong>marketing, marca y empresas</strong> (Flavia), en tres etapas, para discutir juntos.</p>
<p class="meta">17 de noviembre de 2026 · Huellamy · Hecho en Uruguay</p></section>
{''.join(body)}
</body></html>"""
out.write_text(doc, encoding="utf-8")
