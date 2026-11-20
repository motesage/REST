import collections, json, re
import openpyxl, pdfplumber
base = r'D:\Ocean y TimeTech\USERS\Mayling 2026'
rows = list(openpyxl.load_workbook(base + r'\legajos 2026.xlsx', data_only=True).active.values)[1:]
counts = collections.Counter(str(r[4]).strip() for r in rows if r[0] is not None)
schedules = {}
with pdfplumber.open(base + r'\Horarios 2026.pdf') as pdf:
    for page_number, page in enumerate(pdf.pages, 1):
        words = page.extract_words()
        headers = [w for w in words if w['text'] == 'Horario:']
        for i, h in enumerate(headers):
            code = ' '.join(w['text'] for w in words if abs(w['top']-h['top']) < 2 and 55 < w['x0'] and w['x1'] < 110)
            end = headers[i+1]['top'] if i+1 < len(headers) else 800
            body = [w for w in words if h['top']+3 < w['top'] < end-2]
            starts = [w for w in body if re.fullmatch(r'\d\d:\d\d',w['text']) and any(abs(w['x0']-x) < 2 for x in [110.3,237.8,365.3])]
            days = [w for w in body if w['x0'] < 20 and w['text'] not in ['TimeTech']]
            profile = tuple(tuple(w['text'] for w in starts if abs(w['top']-d['top']) < 2) for d in days) if page_number < 12 else None
            schedules[code] = dict(page=page_number, entries=sorted(set(w['text'] for w in starts)), profile=profile)
print('PDF definitions',len(schedules),'assigned schedules',len(counts),'missing',sorted(set(counts)-set(schedules)))
print('All PDF entries',sorted({t for s in schedules.values() for t in s['entries']}))
print('Assigned entries',sorted({t for c in counts for t in schedules[c]['entries']}))
for t in sorted({t for c in counts for t in schedules[c]['entries']}):
    codes=[c for c in counts if t in schedules[c]['entries']]
    print(t,sum(counts[c] for c in codes),','.join(codes))
profiles=collections.defaultdict(list)
for c in counts:
    s=schedules[c]
    if s['page'] < 12 and s['entries']: profiles[s['profile']].append(c)
print('WEEKLY PROFILES',len(profiles))
for p,codes in profiles.items():print(' / '.join('+'.join(d) if d else '-' for d in p),sum(counts[c] for c in codes),','.join(codes))
print('ROTATING',[(c,counts[c],schedules[c]['entries']) for c in counts if schedules[c]['page']==12])
print('NO ENTRIES',[(c,counts[c]) for c in counts if not schedules[c]['entries']])
print('UNASSIGNED',sorted(set(schedules)-set(counts)))
