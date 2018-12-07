import vim
import re
import bibtexparser


def parse_bibtex(fname):
    with open(fname) as bf:
        parser = bibtexparser.bparser.BibTexParser(common_strings=True)
        bd = bibtexparser.load(bf, parser=parser)

    bib = []
    for e in bd.entries:
        nodes = ['ENTRYTYPE', 'journal', 'year', 'title', 'ID']
        d = {}
        for n in nodes:
            d[n.lower()] = e.get(n, None)
        if d['title'] is None or d['id'] is None:
            continue
        d['title'] = re.sub("[}'\\\{]", '', d['title']).strip()
        d['id'] = '[{}]'.format(d['id'])

        author = e.get('author', '').split(' and ')
        d['author'] = []
        for au in author:
            if au:
                last, first = au.split(', ')
                d['author'].append('{}. {}'.format(first[0], last))
            else:
                d['author'] = []
                continue
        if len(d['author']) > 2:
            d['author'] = [d['author'][0], d['author'][-1], 'et al.']
        d['author'] = ', '.join(d['author'])

        nodes = ['entrytype', 'author', 'journal', 'year', 'title', 'id']
        bib.append([d[n] for n in nodes if d[n]])
    vim.command('let l:return = {}'.format(str(bib)))
    return bib


if __name__ == "__main__":
    pass
