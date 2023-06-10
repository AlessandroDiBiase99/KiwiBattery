# KiwiBattery
Description of a battery production system
## Folder and subfolder
In particolare, i file principali da considerare sono:
- **GestoreAnalisiPN.mlapp**  
È l'interfaccia grafica presentata in sezione SubSec:gestoreanalisipn, per agevolare l'acquisizione dei dati da Pipe v3.4, una loro eventuale modifica, il calcolo del grafo di raggiungibilità e la creazione di strutture dati utili per l'elaborazione matematica dei parametri.
- **AnalisiSistemaComposto.m**  
Lo script AnalisiSistemaComposto.m richiama in modo automatico la funzione AnalizzaSistema.m, specificando la versione che si sta analizzando, il nome del macchinario che deve essere analizzato, i rate che devono essere imposti alle transizioni di giunzione di input e di output. Lo script verifica che i throuhgput risultino coerenti tra loro, valutando la necessità di eseguire una seconda analisi dei macchinari. I parametri calcolati sono dunque mostrati a schermo e salvati in file .mat.
- **AnalizzaTokenIterativo.m**  
Lo script AnalizzaTokenIterativo.m modifica il file PN cambiando il token nel posto desiderato da un valore iniziale ad un finale, incrementando ad ogni step il valore in base a quanto specificato. Per ogni configurazione individua il grafo di raggiungibilità e calcola gli indici di prestazione. In particolare viene mostrato l'andamento del thruoghput di input o output al variare dei token presenti, stabilendo il minor numero di token necessari per rispettare la precisione richiesta con il rate imposto.
- **Functions**  
Cartella contenente le funzioni utilizzate nei diversi script:
  - **AnalizzaSistema.m**  
  AnalizzaSistema è una funzione che calcola gli indici di prestazione basandosi sui file .mat PN e Grafo, individuati dai parametri specificati (versione e macchinario). La funzione calcola la matrice di adiacenza, la matrice delle probabilità, il suo riordinamento e la riduzione a U', il calcolo dei valori a regime e degli indici di prestazione.
  - **AnalizzaTokenSingoloMacchinario.m**  
  Tale funzione è analoga ad AnlizzaSistema.m ma è dedicata all'analisi di un singolo macchinario e risulta adattata per soddisfare le specifiche richieste dal contesto.
  - **Calcolo_Iterativo_PN_Grafo.m**  
  Questa funzione permette di calcolare le strutture dati PN e Grafo con capacità del nastro che varia iterativamente in un intervallo di token specificato, per poi salvare tutte le configurazioni in file dal formato .mat.
  - **ServerAttivati.m**
  Tale funzione restituisce il numero di server che risultano attivati in base alla marcatura presente, al numero di token richiesto in ingresso, al numero di token che inibiscono la trasizione e il numero di server totali.
  - **SistemaThroughput.m**  
  Questa funzione completa i valori di throughput per le transizioni immediate, nota la conoscenza dei legami presenti nella GSPN.
  - **VerificaStocastica.m**  
  Tale funzione verifica che la matrice passata come parametro risulti effettivamente stocastica. Si controlla dunque che tutte le righe abbiano sommatoria pari a 1, in caso negativo si provvede a sistemare i valori della matrice al fine di rendere la sommatoria pari a 1. Gli arrotondamenti sono effettuati in base alla precisione passata come parametro.
  - **array2string.m**  
  Questa è una funzione che permette di convertire una struttura dati di tipo array in un vettore di stringhe.
  - **PrintResultForLatex.m**  
  Tale funzione è stata implementata al fine di ottenere in output il codice LaTeX per le tabelle contenenti i diversi indici di prestazione.
  - **ImportaDati.m**  
  Questa funzione, inglobata nella Matlab app GestoreAnalisiPN, permette di estrapolare le matrici che descrivono la rete di Petri dal foglio sheet del file Excel generato da Pipe v4.3.
  - **CalcolaGrafo.m**  
  Questa funzione, inglobata anch'essa nella Matlab app GestoreAnalisiPN, permette di calcolare tutte le marcature raggiungibile da una marcatura iniziale indicata. Vengono calcolate le transizioni abilitate e le conseguenti marcature. Qualora siano calcolate nuove marcature queste vengono analizzate richiamando ciclicamente la funzione.
  - **VisualizzaGrafo.m**  
  Questa funzione, inglobata anch'essa nella Matlab app GestoreAnalisiPN, permette di rappresentare graficamente a schermo il grafo di raggiungibilità che è stato calcolato.
