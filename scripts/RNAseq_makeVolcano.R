library(ggplot2)
library(ggrepel)

degFile = snakemake@input[['degFile']]

FC <- snakemake@params[['FC']]

adjp <- snakemake@params[['adjp']]

contrast <- snakemake@params[['contrast']]

target <- strsplit(contrast, "-vs-")[[1]][1]

baseline <- strsplit(contrast, "-vs-")[[1]][2]

volcano_plot=snakemake@output[['volcano_plot']]

upCol = "#FF9999"
downCol = "#99CCFF"
ncCol = "#CCCCCC"

##----------load differentially expressed genes --------#
print("Loading differential expressed gene table")
print(degFile)

## check if an rda file or tab sep
deg <- read.delim(file=degFile)

head(deg)
dim(deg)

## set all NA missing p-values to 1 (NA is DESeq2 default)
deg[is.na(deg$padj), "padj"] <- 1

## select up regulated genes
up <- deg$padj < adjp & deg$log2FoldChange > log2(FC)
sum(up)

## select down regulated genes
down <- deg$padj < adjp & deg$log2FoldChange < -log2(FC)
sum(down)

# Grab the top 5 up and down regulated genes to label in the volcano plot
if (sum(up)>5) {
  upGenesToLabel <- head(rownames(deg[up,]), 5)
} else if (sum(up) %in% 1:5) {
  upGenesToLabel <- rownames(deg[up,])
}

if (sum(down)>5) {
  downGenesToLabel <- head(rownames(deg[down,]), 5)
} else if (sum(down) %in% 1:5) {
  downGenesToLabel <- rownames(deg[down,])
}

## calculate the -log10(adjp) for the plot
deg$log10padj <- -log10(deg$padj)

# assign up and downregulated genes to a category so that they can be labeled in the plot
deg$Expression <- ifelse(down, 'down',
                  ifelse(up, 'up','NS'))
deg$Expression <- factor(deg$Expression, levels=c("up","down","NS"))

# Assign colours to conditions
if (sum(up)==0 & sum(down)==0) {
  colours <- ncCol
} else if (sum(up)==0) {
  colours <- c(downCol, ncCol)
} else if (sum(down)==0) {
  colours <- c(upCol, ncCol)
} else {
  colours <- c(upCol, downCol, ncCol)
}

# Set all Infinity values to max out at 500 so that all points are contained in the plot
if ("Inf" %in% deg$log10padj) {
  deg$log10padj[deg$log10padj=="Inf"] <- max(deg[is.finite(deg$log10padj),"log10padj"]) + 2
}

deg$Gene <- rownames(deg)

# Assign genes to label based on whether genes are DE or not
if (exists("downGenesToLabel") & exists("upGenesToLabel")) {
  genesToLabel <- c(downGenesToLabel, upGenesToLabel)
} else if (exists("downGenesToLabel") & !exists("upGenesToLabel")) {
  genesToLabel <- downGenesToLabel
} else if (!exists("downGenesToLabel") & exists("upGenesToLabel")) {
  genesToLabel <- upGenesToLabel
}

if (exists("genesToLabel")) {
  p <- ggplot(data=deg, mapping=aes(x=log2FoldChange, y=log10padj, colour=Expression)) +
    geom_vline(xintercept = c(-log2(FC),log2(FC)), linetype="dashed", colour="gray45") +
    geom_hline(yintercept = -log10(adjp), linetype="dashed", colour="gray45") +
    geom_label_repel(aes(label=ifelse(Gene %in% genesToLabel, as.character(Gene),'')),box.padding=0.1, point.padding=0.5, segment.color="gray70", show.legend=FALSE) +
    geom_point() +
    ylab("-log10(FDR)") +
    xlab("log2(Fold Change)") +
    ggtitle(paste(target, "vs", baseline)) +
    scale_colour_manual(values=colours) +
    theme(plot.title = element_text(hjust = 0.5, face="plain"),
          axis.title.x = element_text(size=11),
          axis.title.y = element_text(size=11),
          panel.background = element_blank(),
          axis.line = element_line(colour = "gray45"),
          legend.key = element_rect(fill = "gray96"),
          legend.text = element_text(size = 10))
} else {
  p <- ggplot(data=deg, mapping=aes(x=log2FoldChange, y=log10padj, colour=Expression)) +
    geom_vline(xintercept = c(-log2(FC),log2(FC)), linetype="dashed", colour="gray45") +
    geom_hline(yintercept = -log10(adjp), linetype="dashed", colour="gray45") +
    geom_point() +
    geom_vline(xintercept = c(-log2(FC),log2(FC)), linetype="dashed", colour="gray45") +
    geom_hline(yintercept = -log10(adjp), linetype="dashed", colour="gray45") +
    ylab("-log10(FDR)") +
    xlab("log2(Fold Change)") +
    ggtitle(paste(target, "vs", baseline)) +
    scale_colour_manual(values=colours) +
    theme(plot.title = element_text(hjust = 0.5, face="plain"),
          axis.title.x = element_text(size=11),
          axis.title.y = element_text(size=11),
          panel.background = element_blank(),
          axis.line = element_line(colour = "gray45"),
          legend.key = element_rect(fill = "gray96"),
          legend.text = element_text(size = 10))
}


pdf(volcano_plot)
print({
  p
})
dev.off()
