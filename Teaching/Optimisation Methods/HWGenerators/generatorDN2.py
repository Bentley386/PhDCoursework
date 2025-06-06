import os
import string

from scipy.optimize import linprog
import numpy as np
import re
import subprocess
import pandas as pd
import math
import random
import networkx as nx
import sys
import tqdm

sys.setrecursionlimit(50000)


studentList = "oddana-dn1.csv"
outputHomeworksFolder = "naloge-dn2"


def kao_java_hash(name_priimek):
    # nekaj determinističnega
    return sum(7 ** i * ord(c) for i, c in enumerate(name_priimek)) % 93187


def generateDoublyStochastic():
    # not truly double stochastic, but with constant row/col sums

    iterNum = 6 #choose how many iterations to do
    perms = set()
    A = np.zeros((4,4), dtype=int)

    for i in range(iterNum):
        perm = np.random.permutation(4)
        if tuple(perm) in perms:
            i-=1
            continue
        perms.add(tuple(perm))
        P = np.zeros((4, 4), dtype=int)
        P[np.arange(4), perm] = 1
        coeff = np.random.randint(1,6)
        A = A + coeff*P

    if sum(A[0]) % 2 == 1:
        return generateDoublyStochastic()
    return A


def convertToTex(A):
    text = "\\begin{equation*}\n\\begin{pmatrix}\n"
    sum = np.sum(A[0])

    def fracToText(i):
        if i==0:
            return "0"
        gcd = math.gcd(i,sum)
        num = i//gcd
        denom = sum//gcd
        return f"\\frac{{{num}}}{{{denom}}}"


    for row in A:
        text += "&".join([fracToText(i) for i in row])
        text += "\\\\\n"

    text += "\\end{pmatrix}\n\\end{equation*}\n"
    return text


def generateGraph():
    G = nx.DiGraph()

    withGoods = random.sample(range(1, 13), 6) #which nodes have goods
    supplyStock = -np.random.randint(1,16,3)
    totalSupply = -np.sum(supplyStock)
    demandStock = [np.random.randint(1,totalSupply+1-2)]
    demandStock.append(np.random.randint(1,totalSupply+1-demandStock[-1]-1))
    demandStock.append(totalSupply-sum(demandStock))

    for i in range(6):
        if i<3:
            G.add_node(withGoods[i],demand=supplyStock[i])
        else:
            G.add_node(withGoods[i],demand=demandStock[i-3])

    edges = [(1,2),(2,3),(3,10),(10,11),(11,12),(12,9),(9,8),(8,7),(7,4),(4,1),
             (4,5),(5,6),(6,11),(2,5),(5,8),(3,6),(6,9),
             (4,2),(4,8),(2,6),(6,8),(3,11),(9,11)]

    for e in edges:
        if np.random.rand() < 0.5:
            G.add_edge(e[0],e[1])
        else:
            G.add_edge(e[1],e[0])

    try:
        nx.network_simplex(G,demand="demand")
    except nx.NetworkXUnfeasible as e:
        return G
    except Exception as e:
        return generateGraph()
    else:
        return generateGraph()

G = generateGraph()

def graphToTex(G):
    text = r"\NewEnviron{razvoz@grafA}{"
    nodes = r"""\vozlisce{a}{xyz polar cs:angle=135,radius=2.828}
	\vozlisce{b}{xyz polar cs:angle=90,radius=2}
	\vozlisce{c}{xyz polar cs:angle=45,radius=2.828}
	\vozlisce{d}{xyz polar cs:angle=180,radius=2}
	\vozlisce{e}{xyz polar cs:angle=0,radius=0}
	\vozlisce{f}{xyz polar cs:angle=0,radius=2}
	\vozlisce{g}{xyz polar cs:angle=225,radius=2.828}
	\vozlisce{h}{xyz polar cs:angle=270,radius=2}
	\vozlisce{i}{xyz polar cs:angle=315,radius=2.828}
	\vozlisce{j}{xyz polar cs:angle=26.57, radius=4.4721}
	\vozlisce{k}{xyz polar cs:angle=0,radius=4}
	\vozlisce{l}{xyz polar cs:angle=-26.57,radius=4.4721}
	"""
    nodes = nodes.split("\n")
    for node in G.nodes(data=True):
        if "demand" in node[1]:
            dem = node[1]["demand"]
            nodes[node[0]-1] += f"[{dem}]"
    text += "\n".join(nodes)
    text += "\n"
    above = {(1,2),(2,3),(3,6),(1,4),(2,6),(2,4),
             (4,5),(5,6),(2,5),(5,8),(6,11),(3,10),(9,11),(10,11),(11,12),(3,11)}

    mapping = {i + 1: letter for i, letter in enumerate(string.ascii_lowercase)}

    for e in G.edges:
        price = np.random.randint(0,10)
        node1 = mapping[e[0]]
        node2 = mapping[e[1]]
        if e in above or (e[1],e[0]) in above:
            orient = "above"
        else:
            orient = "below"
        text+= f"\\povezava{{{node1}}}{{{node2}}}{{{price}}}[sloped]{{{orient}}}\n"
    text+="}\n"

    text += "\\begin{razvoz}[scale=1.5]{grafA}\\end{razvoz}\n"
    return text


def generate_transport_with_parameter(ime_priimek):
    def zamik_updater(cena_match):
        nova_cena = int(cena_match.group(2)) + zamik
        return f"{{{nova_cena}}}"

    rng = np.random.default_rng(kao_java_hash(ime_priimek))

    faktor = rng.integers(1, 4)
    ponudbe_povprasevanja = [x * faktor for x in [10, -5, -10, 5]]

    cene = {}
    cene["ba"] = rng.integers(8, 13)
    cene["bd"] = rng.integers(1, 5)
    cene["da"] = 7 - cene["bd"]
    cene["hd"] = rng.integers(14, 20)
    cene["gh"] = 21 - cene["hd"]
    cene["he"] = 14 - cene["gh"]
    cene["ed"] = cene["hd"] - cene["he"] + 1
    cene["be"] = cene["ed"] - cene["bd"] + 1


    tex_code = r"""\question[] V odvisnosti od $\alpha \in \mathbb{R}$ najdi najcenejši razvoz in njegovo ceno:
    
    \NewEnviron{razvoz@grafParameter}{
		\vozlisce{a}{xyz polar cs:angle=135,radius=2.828}[@povp0]
		\vozlisce{b}{xyz polar cs:angle=90,radius=2}
		\vozlisce{c}{xyz polar cs:angle=45,radius=2.828}[@povp1]
		\vozlisce{d}{xyz polar cs:angle=180,radius=2}
		\vozlisce{e}{xyz polar cs:angle=0,radius=0}
		\vozlisce{f}{xyz polar cs:angle=0,radius=2}
		\vozlisce{g}{xyz polar cs:angle=225,radius=2.828}[@povp2]
		\vozlisce{h}{xyz polar cs:angle=270,radius=2}
		\vozlisce{i}{xyz polar cs:angle=315,radius=2.828}[@povp3]
		
		% zunaj
		\povezava{b}{a}{@ba}[sloped]{above}
		\povezava{c}{b}{2}[sloped]{above}
		\povezava{f}{c}{3}[sloped]{above}
		\povezava{i}{f}{2}[sloped]{below}
		\povezava{h}{i}{1}[sloped]{below}
		\povezava{g}{h}{@gh}[sloped]{below}
		\povezava{d}{g}{7}[sloped]{below}
		\povezava{d}{a}{@da}[sloped]{above}
		% poshrek
		\povezava{h}{d}{@hd}[sloped]{below}
		\povezava{h}{f}{4}[sloped]{below}
		\povezava{f}{b}{\alpha}[sloped]{above}
		\povezava{b}{d}{@bd}[sloped]{above}
		% notranji +
		\povezava{b}{e}{@be}[sloped]{above}
		\povezava{f}{e}{8}[sloped]{above}
		\povezava{e}{d}{@ed}[sloped]{above}
		\povezava{h}{e}{@he}[sloped]{above}
	}
	
	\begin{razvoz}[scale=1.5]{grafParameter}
	\end{razvoz}
    """

    for i, povp in enumerate(ponudbe_povprasevanja):
        tex_code = tex_code.replace(f"@povp{i}", str(povp))

    for ime, vrednost in cene.items():
        tex_code = tex_code.replace(f"@{ime}", str(vrednost))
    zamik = 0 # preveč pogrša :) rng.integers(-5, 5)
    tex_code = re.sub(r"(\{(\d+)\})", zamik_updater, tex_code)
    return tex_code


def generate_transport_with_constraints(ime_priimek):
    class Povezava:
        def __init__(self, cena, kapaciteta):
            self.cena = cena
            self.kapaciteta = kapaciteta

        def __repr__(self):
            return f"[{self.kapaciteta}]{{{self.cena}}}"

    rng = np.random.default_rng(kao_java_hash(ime_priimek))

    ponudbe_povprasevanja = [-3, 4, -5, 6, -2]
    # najprej stranica, nato diagonala
    povezave = [
        [Povezava(1, 1), Povezava(2, rng.integers(2, 11))],
        [Povezava(rng.integers(3, 11), rng.integers(1, 11)), Povezava(2, rng.integers(4, 11))],
        [Povezava(1, 2), Povezava(7, 5)],
        [Povezava(rng.integers(5, 11), rng.integers(1, 11)), Povezava(rng.integers(4, 11), rng.integers(1, 11))],
        [Povezava(rng.integers(4, 11), rng.integers(1, 11)), Povezava(4, rng.integers(7, 11))],
    ]
    zamik = rng.integers(0, 5)
    tex_code = r"""\question[] Najdi najcenejši razvoz na spodnjem grafu
    (gre za petkotnik s petimi diagonalami, ki smo jih zaradi berljivosti malo ukrivili):
    
    \NewEnviron{razvoz@razvozOmejitve}{
		\vozlisce{a}{xyz polar cs:angle=72, radius=3}[@povp0]
		\vozlisce{b}{xyz polar cs:angle=144,radius=3}[@povp1]
		\vozlisce{c}{xyz polar cs:angle=216,radius=3}[@povp2]
		\vozlisce{d}{xyz polar cs:angle=288,radius=3}[@povp3]
		\vozlisce{e}{xyz polar cs:angle=0,radius=3}[@povp4]
		
		% zunaj
		\povezava{a}{b}@stran0[sloped]{below}
		\povezava{b}{c}@stran1[sloped]{below}
		\povezava{c}{d}@stran2[sloped]{above}[bend right=20]
		\povezava{d}{e}@stran3[sloped]{above}
		\povezava{e}{a}@stran4[sloped]{above}
		
		% diag
		\povezava{a}{c}@diag0[sloped]{above}[bend right=70, looseness=2.5]
		\povezava{b}{d}@diag1[sloped]{below}
		\povezava{c}{e}@diag2[sloped]{below}[bend right=70, looseness=2.5]
		\povezava{d}{a}@diag3[sloped]{above}
		\povezava{e}{b}@diag4[sloped]{below}[bend right=70, looseness=2.5]
	}
	
	
	\begin{razvoz}[scale=1.5]{razvozOmejitve}
	\end{razvoz}
	
	
    """
    for i in range(5):
        povp = ponudbe_povprasevanja[(i + zamik) % 5]
        stranica, diagonala = map(str, povezave[(i + zamik) % 5])
        tex_code = tex_code.replace(f"@povp{i}", f"{povp}")
        tex_code = tex_code.replace(f"@stran{i}", stranica)
        tex_code = tex_code.replace(f"@diag{i}", diagonala)
    return tex_code


def generateHW(name, lastname, outputFolder):
    # pozabu vgrajeno python forico
    brez_sumnikov = f"{name}_{lastname}".replace(" ", "_").lower()
    for bad, good in [["č", "c"], ["ž", "z"], ["š", "s"], ["đ", "d"], ["ć", "c"]]:
        brez_sumnikov = brez_sumnikov.replace(bad, good)
    filename = f'DN2_{brez_sumnikov}'
    pdf = f"{filename}.pdf"
    if os.path.exists(os.path.join(outputFolder, pdf)):
        return False, pdf


    tex = r"""\documentclass[12pt,letterpaper, onecolumn]{exam}
    \usepackage{amsmath}
    \usepackage{eurosym}
    \usepackage{amssymb}
    \usepackage[T1]{fontenc}
    \usepackage{omrezja}
    \usepackage[lmargin=71pt, tmargin=1.2in]{geometry}  %For centering solution box
    \usetikzlibrary{calc}
    \usetikzlibrary{matrix}
    \tikzstyle{velikost vozlisca razvoza}=[minimum size=8mm]
    
    \lhead{Leaft Header\\}
    \rhead{Right Header\\}
    % \chead{\hline} % Un-comment to draw line below header
    \pagestyle{empty}   %For removing header/footer from page 1

    \begin{document}
    \pointformat{}

    \begingroup  
    \centering
    {\small \textsc{Univerzitetni študij finančne matematike} \par}

    {\LARGE \textsc{OPTIMIZACIJSKE METODE}\par}
    {\large \textit{Domača naloga: razvozi} \par}
 \vspace{0.5cm}
    {\Large """
    tex += f"{name} {lastname}"
    tex += r"""\par}
    {\large Rok za oddajo: 28.~4.~2025 \par}
    \rule{\textwidth}{0.4pt}
    \pointsdroppedatright   %Self-explanatory
    \printanswers
    \renewcommand{\solutiontitle}{\noindent\textbf{Ans:}\enspace}   %Replace "Ans:" with starting keyword in solution box
    """

    tex += "\n\\begin{questions}\n"

    tex += "\\question[] Zapiši sledečo matriko kot konveksno kombinacijo permutacijskih matrik:\n"
    A = generateDoublyStochastic()
    tex += convertToTex(A)
    tex += "\\question[] Z dvofazno simpleksno metodo na omrežjih pokaži, da je sledeč problem nedopusten:\n"
    G = generateGraph()
    tex += graphToTex(G)

    tex += generate_transport_with_parameter(name + lastname)
    tex += generate_transport_with_constraints(name + lastname)

    tex += "\\end{questions}\n \\end{document}"

    with open("temp.tex", "w", encoding="utf-8") as f:
        f.write(tex)

    subprocess.run(['pdflatex', '-jobname', filename, '-output-directory', outputFolder, "temp.tex"], check=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    return True, pdf


generateHW("Ime","Priimek","Naloge")

def generiraj_tabelo(filenames, output_dir):
    cells = [
        f'<td style="padding: 5px;"><a href="https://ucilnica.fmf.uni-lj.si/pluginfile.php/167279/mod_folder/content/0/{file}?forcedownload=1">{person}</a></td>'
        for file, person in filenames
    ]
    rows = []
    for i in range(0, len(cells), 5):
        cells_for_row = cells[i:i + 5]
        cells_for_row += ["<td></td>"] * (5 - len(cells_for_row))  # Fill with empty cells if needed
        row = "\n  ".join(cells_for_row)
        rows.append(f"<tr>\n  {row}\n</tr>")
    rows_str = "\n".join(rows)

    with open(os.path.join(output_dir, "_tabela.html"), "w", encoding="utf-8") as f:
        print(f"""
    <table style="border-collapse: collapse; border-width: 2px;" border="1">
        <thead align="center"></thead>
        <tbody align="left">
        {rows_str}         
        </tbody>
    </table>
    """, file=f)


def generate_all():
    df = pd.read_csv(studentList, encoding="UTF-8", sep=";")
    names = df["Ime"].values
    last_names = df["Priimek"].values

    # generate pdf
    filenames = []
    skipped = 0
    for name, last_name in tqdm.tqdm(zip(names, last_names), total=len(names)):
        generated, file = generateHW(name, last_name, outputHomeworksFolder)
        if not generated:
            skipped += 1
        filenames.append((file, f"{name} {last_name}"))
    print(f"Skipped {skipped}/{len(filenames)} files as they already existed.")

    # clean up non-pdf files
    for file in os.listdir(outputHomeworksFolder):
        if not file.endswith(".pdf"):
            os.remove(os.path.join(outputHomeworksFolder, file))

    # generate učilnica html
    generiraj_tabelo(filenames, outputHomeworksFolder)
    return filenames



#generate_all()
