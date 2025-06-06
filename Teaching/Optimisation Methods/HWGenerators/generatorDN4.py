import os
import time

from scipy.optimize import linprog
import numpy as np
import subprocess
import pandas as pd
import sys
import tqdm
import re
import requests

sys.setrecursionlimit(50000)

HOMEWORK_NAME = __file__[__file__.rfind("DN") : __file__.rfind(".")].upper()
studentList = "oddana-dn1-dn2-dn3.csv"
OUTPUT_HOMEWORKS_FOLDER = f"naloge-{HOMEWORK_NAME}".lower()
ID_MAPE_NA_UCILNICI = "168314"  # najprej naredi mapo na učilnici, potem pa to popravi


def kao_java_hash(name_priimek):
    # nekaj determinističnega
    return sum(7**i * ord(c) for i, c in enumerate(name_priimek)) % 93187


def generate_naloga1(ime_priimek: str):
    """Zgenerira nalogo o konveksnih množicah."""

    def doloci_b_koordinato(spodnja, zgornja):
        b = rng.integers(spodnja**2, zgornja**2)
        while b in popolni_kvadrati:
            b = rng.integers(spodnja**2, zgornja**2)
        return b

    rng = np.random.default_rng(kao_java_hash(ime_priimek))
    text = r"""\question[] Naj bosta $I\subset\mathbb{R}^2$ množica tistih točk v ravnini, ki imajo obe koordinati iracionalni
    (npr.~$(\pi, e)\in I$, ampak $(\pi, 0)\notin I$), ter $Q\subset\mathbb{R}^2$ množica tistih točk v ravnini, 
    ki imajo obe koordinati racionalni (npr.~$(1, 0)\in Q$, ampak $(\pi, 0)\notin Q$).
    
    Naj bosta $A$ in $B$ konveksni ogrinjači množic $([@xA0, @xA1]\times [@yA0, @yA1])\cap I$ in
     $([\sqrt{@xB0}, \sqrt{@xB1}]\times [\sqrt{@yB0}, \sqrt{@yB1}])\cap Q$.
    Poenostavljeno zapiši $A$ in $B$. Ali sta $A\cap B$ in $A\cup B$ konveksni?
    
    """

    #
    #     BBBBBBB
    # AAAABABABBB
    # AAAABABABBB
    # AAAAAAAA

    popolni_kvadrati = {x**2 for x in range(100)}  # bo dost :)

    parametri = {}
    # A naj ima racionalne meje = cela števila
    parametri["xA0"] = rng.integers(1, 5)
    parametri["xA1"] = rng.integers(parametri["xA0"] + 4, parametri["xA0"] + 8)
    parametri["yA0"] = rng.integers(1, 5)
    parametri["yA1"] = rng.integers(parametri["yA0"] + 4, parametri["yA0"] + 8)
    # B naj ima iracionalne meje.
    parametri["xB0"] = doloci_b_koordinato(parametri["xA0"] + 1, parametri["xA1"] - 1)
    parametri["xB1"] = doloci_b_koordinato(parametri["xA1"] + 1, parametri["xA1"] + 5)
    parametri["yB0"] = doloci_b_koordinato(parametri["yA0"] + 1, parametri["yA1"] - 1)
    parametri["yB1"] = doloci_b_koordinato(parametri["yA1"] + 1, parametri["yA1"] + 5)

    for ime, vrednost in parametri.items():
        text = text.replace(f"@{ime}", str(vrednost))
    return text


def generateDomain(seed, numRows, numCols, feasible):
    """
    :param seed:
    :param numRows: num of rows in Ax<=b
    :param numCols:  num of cols in Ax<=b
    :param feasible: find a feasible set
    :return:
    """

    if feasible:  # We don't have bounds on vars for KKT
        bounds = (None, None)
    else:
        bounds = (0, None)  # want x>= 0 for Farkas

    np.random.seed(seed)
    c = np.ones(numCols)
    while True:
        A = np.random.randint(-20, 20, (numRows, numCols))
        if np.any(A == 0):
            continue  # Just for simplicity let's have nonzero comps.
        b = np.random.randint(-20, 20, numRows)
        sol = linprog(-c, A, b, bounds=bounds)

        if feasible and sol.status == 0:
            return (A, b)
        if not feasible and sol.status == 2:
            return (A, b)


def generate_naloga2(ime_priimek):
    """
    Zgenerira Farkas nalogo

    :param ime_priimek:
    :return:
    """

    text = "\\question[] S pomočjo Farkaseve leme dokaži, da je sledeč problem nedopusten:\n"

    seed = kao_java_hash(ime_priimek)
    A, b = generateDomain(seed, 3, 4, False)

    text += "\\begin{alignat*}{4}\n \\mathrm{max}\\  2x &+ 3y &- 4z &+ 5w& \\\\ \n"

    variables = ["x", "y", "z", "w"]

    def stringifyRow(row):
        rowStr = [str(row[j]) + variables[j] for j in range(len(row))]
        for j in range(len(row)):
            if row[j] == 1:
                rowStr[j] = variables[j]
            elif row[j] == -1:
                rowStr[j] = "-" + variables[j]
            elif row[j] == 0:
                rowStr[j] = "\\phantom{0y}"
        return rowStr

    for i in range(len(A)):
        row = A[i]
        text += "&+".join(stringifyRow(row)) + "& &\\leq" + str(b[i]) + "\\\\"
    text = text[:-2]  ##remove the \\
    text += "\\end{alignat*}\n"
    text += "\\vspace{-\\baselineskip}"

    text += "\\begin{equation*}\n"
    text += ",".join(variables) + "\\geq 0"
    text += "\\end{equation*}\n"
    text = re.sub(r"\+-", "-", text)
    text = re.sub(r"\+\\phantom{0y}", r"\\phantom{0y}", text)
    return text


from fractions import Fraction


def generate_naloga3(ime_priimek):
    """Drugi odvod naj bo (e^x - (x + 1))(x - a)

    2x integral je torej [WA] ...
    """

    class Ulomek(Fraction):
        def __str__(self):
            a = self.numerator
            b = self.denominator
            if b < 0:
                a = -a
                b = -b
            a = abs(a)
            if b == 1:
                if a == 1:
                    return ""
                return str(a)
            return f"\\frac{{{a}}}{{{b}}}"

    rng = np.random.default_rng(kao_java_hash(ime_priimek))
    a = rng.integers(3, 20)
    text = r"""\question[] Na katerem območju je konveksna funkcija
    $$f(x) = e^x (x - @p1) - \frac{1}{12} x^4 + @p2 x^3 + @p3 x^2 + \sqrt[2025]{@p4} x + \pi^{@p5}\; ?$$
    Namig: ustrezen izraz zapiši kot produkt dveh členov.
    
    """
    parametri = {
        "p1": a + 2,
        "p2": str(Ulomek(1 - a, 6)),
        "p3": str(Ulomek(a, 2)),
        "p4": rng.integers(100, 200),
        "p5": rng.integers(2, 10),
    }
    for ime, vrednost in parametri.items():
        text = text.replace(f"@{ime}", str(vrednost))
    return text


def generate_naloga4():
    return r"""\question[] Dokaži, da za poljubni množici $A$ in $B$ velja: 
    $A\subseteq B\Longrightarrow \text{conv}(A)\subseteq \text{conv}(B)$.
    Najdi par množic $A$ in $B$, za kateri velja $A\neq B$ in hkrati $\text{conv}(A) = \text{conv}(B)$.
    
    """


def generate_naloga5(ime_priimek):
    """
    Zgenerira KKT nalogo

    :param ime_priimek:
    :return:
    """

    text = (
        "\\question[] S pomočjo Karush-Kuhn-Tucker pogojev poišči minimum funkcije:\n"
    )
    seed = kao_java_hash(ime_priimek)
    np.random.seed(seed)

    vars = ["x^2", "xy", "y^2", "x", "y", ""]

    def stringifyRow(row, vars):
        rowStr = [str(row[j]) + vars[j] for j in range(len(row))]
        for j in range(len(row)):
            if row[j] == 1:
                rowStr[j] = vars[j]
            elif row[j] == -1:
                rowStr[j] = "-" + vars[j]
        return rowStr

    coeff1 = np.random.randint(
        1, 11, 3
    )  # first 3 coeffs are positive so the problem isnt unbounded
    coeff2 = np.random.choice(np.concatenate((np.arange(-10, 0), np.arange(1, 11))), 3)
    coeff = np.concatenate((coeff1, coeff2))

    text += "\\begin{equation*}\n"
    text += "f(x,y) = " + "+".join(stringifyRow(coeff, vars)) + "\n"
    text += "\\end{equation*}\n"
    text += "na območju:\n"
    text += "\\begin{equation*}\n"

    A, b = generateDomain(seed, 3, 2, True)

    variables = ["x", "y"]
    text += r"D = \{ (x,y) \in \mathbb{R}^2 ;"
    conds = [
        "+".join(stringifyRow(A[i], variables)) + " \\leq " + str(b[i])
        for i in range(3)
    ]
    text += ",".join(conds) + "\\}\n"
    text += "\\end{equation*}"

    text = re.sub(r"\+-", "-", text)
    text = re.sub(r"\+\\phantom{0y}", r"\\phantom{0y}", text)
    return text


def generateHW(name, lastname, outputFolder, debug=False):
    # pozabu vgrajeno python forico
    brez_sumnikov = f"{name}_{lastname}".replace(" ", "_").lower()
    for bad, good in [["č", "c"], ["ž", "z"], ["š", "s"], ["đ", "d"], ["ć", "c"]]:
        brez_sumnikov = brez_sumnikov.replace(bad, good)
    filename = f"{HOMEWORK_NAME}_{brez_sumnikov}"
    pdf = f"{filename}.pdf"
    if os.path.exists(os.path.join(outputFolder, pdf)):
        return False, pdf

    tex = r"""\documentclass[12pt,letterpaper, onecolumn]{exam}
    \usepackage{amsmath}
    \usepackage{eurosym}
    \usepackage{amssymb}
    \usepackage[T1]{fontenc}
    \usepackage[lmargin=71pt, tmargin=1.2in]{geometry}  %For centering solution box
    
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
    {\large \textit{Domača naloga: konveksnost} \par}
 \vspace{0.5cm}
    {\Large """
    tex += f"{name} {lastname}"
    tex += r"""\par}
    {\large Rok za oddajo: 23.~5.~2025 \par}
    \rule{\textwidth}{0.4pt}
    \pointsdroppedatright   %Self-explanatory
    \printanswers
    \renewcommand{\solutiontitle}{\noindent\textbf{Ans:}\enspace}   %Replace "Ans:" with starting keyword in solution box
    """

    tex += "\n\\begin{questions}\n"

    tex += generate_naloga1(name + lastname)
    tex += generate_naloga2(name + lastname)
    tex += generate_naloga3(name + lastname)
    tex += generate_naloga4()
    tex += generate_naloga5(name + lastname)

    tex += "\\end{questions}\n \\end{document}"

    with open("temp.tex", "w", encoding="utf-8") as f:
        f.write(tex)

    subprocess.run(
        [
            "pdflatex",
            "-jobname",
            filename,
            "-output-directory",
            outputFolder,
            "temp.tex",
        ],
        check=True,
        stderr=None if debug else subprocess.DEVNULL,
        stdout=None if debug else subprocess.DEVNULL,
    )
    return True, pdf


generateHW("Ime","Priimek","./")

def generiraj_tabelo(filenames, output_dir):
    cells = [
        f'<td style="padding: 5px;"><a href="https://ucilnica.fmf.uni-lj.si/pluginfile.php/{ID_MAPE_NA_UCILNICI}/mod_folder/content/0/{file}?forcedownload=1">{person}</a></td>'
        for file, person in filenames
    ]
    rows = []
    for i in range(0, len(cells), 5):
        cells_for_row = cells[i : i + 5]
        cells_for_row += ["<td></td>"] * (
            5 - len(cells_for_row)
        )  # Fill with empty cells if needed
        row = "\n  ".join(cells_for_row)
        rows.append(f"<tr>\n  {row}\n</tr>")
    rows_str = "\n".join(rows)

    with open(os.path.join(output_dir, "_tabela.html"), "w", encoding="utf-8") as f:
        print(
            f"""
    <table style="border-collapse: collapse; border-width: 2px;" border="1">
        <thead align="center"></thead>
        <tbody align="left">
        {rows_str}         
        </tbody>
    </table>
    """,
            file=f,
        )


def generate_all():
    df = pd.read_csv(studentList, encoding="UTF-8", sep=";")
    print("Vseh:", len(df), df.columns)
    df_ok = df[(df["Oddana 2."] == "x") & (df["Oddana 3."] == "x")]
    print("Oddanih:", len(df_ok))
    names = df_ok["Ime"].values
    last_names = df_ok["Priimek"].values
    neoddani = sorted(set(df["Priimek"].values) - set(df_ok["Priimek"].values))
    print("Neoddani:", len(neoddani), neoddani)

    # generate pdf
    filenames = []
    skipped = 0
    for name, last_name in tqdm.tqdm(zip(names, last_names), total=len(names)):
        generated, file = generateHW(name, last_name, OUTPUT_HOMEWORKS_FOLDER)
        if not generated:
            skipped += 1
        filenames.append((file, f"{name} {last_name}"))
    print(f"Skipped {skipped}/{len(filenames)} files as they already existed.")

    # clean up non-pdf files
    for file in os.listdir(OUTPUT_HOMEWORKS_FOLDER):
        if not file.endswith(".pdf"):
            os.remove(os.path.join(OUTPUT_HOMEWORKS_FOLDER, file))

    # generate učilnica html
    generiraj_tabelo(filenames, OUTPUT_HOMEWORKS_FOLDER)
    return filenames


