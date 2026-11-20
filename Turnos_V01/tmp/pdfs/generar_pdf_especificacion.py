from pathlib import Path
import re, html, textwrap
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, LongTable, TableStyle, Preformatted
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
import pypdfium2 as pdfium
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[2]
source = root / 'Especificacion_JSON_Turnos_Requerida_SAGE_v1_2_20261012.md'
out = root / 'output/pdf/Especificacion_JSON_Turnos_Requerida_SAGE_v1_2_20261012.pdf'
out.parent.mkdir(parents=True, exist_ok=True)
qa = root / 'tmp/pdfs/qa_v1_2'
qa.mkdir(parents=True, exist_ok=True)
for name, filename in [('Arial','arial.ttf'),('ArialBold','arialbd.ttf'),('Mono','consola.ttf')]:
    pdfmetrics.registerFont(TTFont(name, str(Path('C:/Windows/Fonts') / filename)))
styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='BodyS', fontName='Arial', fontSize=9.5, leading=13, spaceAfter=6))
styles.add(ParagraphStyle(name='CellS', fontName='Arial', fontSize=8.3, leading=11))
styles.add(ParagraphStyle(name='HeadS', fontName='ArialBold', fontSize=8.3, leading=11))
for n, size in [('Title',19),('Heading1',14),('Heading2',11.5)]:
    styles[n].fontName='ArialBold'; styles[n].fontSize=size; styles[n].leading=size+4; styles[n].textColor=colors.black
styles.add(ParagraphStyle(name='CodeS',fontName='Mono',fontSize=8.2,leading=10.5,spaceAfter=3))

def inline(s):
    s = s.replace('\u2011','-')
    links=[]
    def link(m):
        label, url=m.group(1),m.group(2)
        if url.startswith(('https://','http://')):
            v='<link href="'+html.escape(url,quote=True)+'" color="#204c75">'+html.escape(label)+'</link>'
        else:
            v=html.escape(label)
        links.append(v); return f'ZZLINK{len(links)-1}ZZ'
    s=re.sub(r'\[([^\]]+)\]\(([^)]+)\)',link,s)
    s=html.escape(s)
    s=re.sub(r'\*\*(.+?)\*\*',r'<b>\1</b>',s)
    s=re.sub(r'`([^`]+)`',lambda m:'<font name="Mono">'+m.group(1)+'</font>',s)
    for j,v in enumerate(links): s=s.replace(f'ZZLINK{j}ZZ',v)
    return s

lines=source.read_text(encoding='utf-8-sig').splitlines()
story=[]; i=0; width=landscape(A4)[0]-72
while i<len(lines):
    line=lines[i].strip()
    if not line: i+=1; continue
    if line.startswith('```'):
        i+=1; code=[]
        while i<len(lines) and not lines[i].strip().startswith('```'):
            code.extend(textwrap.wrap(lines[i],width=135,replace_whitespace=False,drop_whitespace=False) or ['']); i+=1
        for c in code: story.append(Preformatted(c,styles['CodeS']))
        story.append(Spacer(1,8)); i+=1; continue
    if line.startswith('|'):
        rows=[]
        while i<len(lines) and lines[i].strip().startswith('|'):
            cells=[x.strip() for x in lines[i].strip().strip('|').split('|')]
            if not all(re.fullmatch(r'[:\- ]+',c) for c in cells): rows.append(cells)
            i+=1
        count=len(rows[0])
        if count==7: ratios=[.035,.19,.085,.045,.25,.17,.225]
        elif count==4: ratios=[.17,.23,.32,.28]
        elif count==3: ratios=[.19,.35,.46]
        else: ratios=[1/count]*count
        widths=[width*r/sum(ratios) for r in ratios]
        data=[[Paragraph(inline(c),styles['HeadS' if n==0 else 'CellS']) for c in row] for n,row in enumerate(rows)]
        table=LongTable(data,colWidths=widths,repeatRows=1,hAlign='LEFT')
        table.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#e5eaf0')),('GRID',(0,0),(-1,-1),.45,colors.HexColor('#d0d0d0')),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('LEFTPADDING',(0,0),(-1,-1),6),('RIGHTPADDING',(0,0),(-1,-1),6),('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6)]))
        story.extend([table,Spacer(1,10)]); continue
    if line.startswith('#'):
        level=len(line)-len(line.lstrip('#'))
        style='Title' if level==1 else 'Heading1' if level==2 else 'Heading2'
        story.append(Paragraph(inline(line.lstrip('#').strip()),styles[style])); i+=1;continue
    para=[line];i+=1
    if not re.match(r'(- |\d+\. )',line):
        while i<len(lines) and lines[i].strip() and not re.match(r'(#|\||```|- |\d+\. )',lines[i].strip()):
            para.append(lines[i].strip());i+=1
    story.append(Paragraph(inline(' '.join(para)),styles['BodyS']))

def footer(canvas,doc):
    canvas.setFont('Arial',8)
    canvas.setFillColor(colors.HexColor('#555555'))
    canvas.drawString(36,22,'SAGE - Especificación JSON Turnos - Revisión documental 1.2')
    canvas.drawRightString(landscape(A4)[0]-36,22,str(doc.page))

doc=SimpleDocTemplate(str(out),pagesize=landscape(A4),rightMargin=36,leftMargin=36,topMargin=32,bottomMargin=38,title='Especificación del JSON de turnos requerida por SAGE',author='SAGE')
doc.build(story,onFirstPage=footer,onLaterPages=footer)
pdf=pdfium.PdfDocument(str(out))
thumbs=[]
for n,page in enumerate(pdf):
    im=page.render(scale=1.3).to_pil();im.save(qa/f'page-{n+1:02}.png')
    im.thumbnail((500,355)); thumb=Image.new('RGB',(520,385),'#cccccc');thumb.paste(im,(10,20));ImageDraw.Draw(thumb).text((10,3),f'Página {n+1}',fill='black');thumbs.append(thumb)
for group in range(0,len(thumbs),6):
    sheet=Image.new('RGB',(1560,770),'white')
    for j,im in enumerate(thumbs[group:group+6]):sheet.paste(im,((j%3)*520,(j//3)*385))
    sheet.save(qa/f'contact-{group//6+1}.png')
print(f'PDF: {out}\nPáginas: {len(pdf)}\nQA: {qa}')
