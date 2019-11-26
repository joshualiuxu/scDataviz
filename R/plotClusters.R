plotClusters <- function(
  sce,
  ncol = 3,
  nrow = 2,

  col,
  pointSize = 0.5,

  legendPosition = 'none',
  legendLabSize = 12,
  legendIconSize = 5.0,
  xlim = NULL,
  ylim = NULL,

  label = TRUE,
  labSize = 3.0,
  labhjust = 1.5,
  labvjust = 0,
  drawConnectors = TRUE,
  widthConnectors = 0.5,
  colConnectors = 'grey50',

  xlab = 'UMAP1',
  xlabAngle = 0,
  xlabhjust = 0.5,
  xlabvjust = 0.5,

  ylab = 'UMAP2',
  ylabAngle = 0,
  ylabhjust = 0.5,
  ylabvjust = 0.5,
  axisLabSize = 16,

  title = NULL,
  subtitle = NULL,
  caption = NULL,
  titleLabSize = 16,
  subtitleLabSize = 12,
  captionLabSize = 12,

  hline = NULL,
  hlineType = 'longdash',
  hlineCol = 'black',
  hlineWidth = 0.4,
  vline = NULL,
  vlineType = 'longdash',
  vlineCol = 'black',
  vlineWidth = 0.4,

  gridlines.major = TRUE,
  gridlines.minor = TRUE,
  borderWidth = 0.8,
  borderColour = 'black')
{
  # create a base theme that will later be modified
  th <- theme_bw(base_size=24) +

    theme(
      legend.background=element_rect(),

      title=element_text(size=legendLabSize),

      plot.title=element_text(angle=0, size=titleLabSize,
        face='bold', vjust=1),
      plot.subtitle=element_text(angle = 0, size = subtitleLabSize,
        face = 'plain', vjust = 1),
      plot.caption=element_text(angle = 0, size = captionLabSize,
        face = 'plain', vjust = 1),

      axis.text.x=element_text(angle = xlabAngle, size = axisLabSize,
        hjust = xlabhjust, vjust = xlabvjust),
      axis.text.y=element_text(angle = ylabAngle, size = axisLabSize,
        hjust = ylabhjust, vjust = ylabvjust),
      axis.title=element_text(size=axisLabSize),

      legend.title=element_blank(),
      legend.position=legendPosition,
      legend.key=element_blank(),
      legend.key.size=unit(0.5, 'cm'),
      legend.text=element_text(size=legendLabSize))

  plotobj <- as.data.frame(reducedDim(sce, "UMAP"))

  plotobj <- data.frame(plotobj, as.data.frame(t(assay(sce, 'scaled'))))

  plotobj <- melt(plotobj, id.vars = c('UMAP1','UMAP2','Cluster'))

  colnames(plotobj) <- c('UMAP1','UMAP2','Marker','Expression')

  # set labels
  if (label == TRUE) {
    ggdata$plotobj <- paste0('Cluster', ggdata$Cluster)
    ggdata$plotobj[duplicated(ggdata$lab)] <- NA
  }

  if (is.null(xlim)) {
    xlim <- c(
      min(plotobj[,'UMAP1'], na.rm = TRUE) - 1,
      max(plotobj[,'UMAP1'], na.rm = TRUE) + 1)
  }

  if (is.null(ylim)) {
    ylim <- c(
      min(plotobj[,'UMAP2'], na.rm = TRUE) - 1,
      max(plotobj[,'UMAP2'], na.rm = TRUE) + 1)
  }

  # order by expression level to ensure that highly expressed are coloured last
  plotobj <- plotobj[order(plotobj$Expression, decreasing = FALSE),]

  # initialise the plot object
  plot <- ggplot(plotobj, aes(x = UMAP1, y = UMAP2)) + th +

    guides(
      fill = guide_legend(),
      shape = guide_legend(),
      alpha = FALSE)

  plot <- plot + geom_point(aes(colour = Expression), size = pointSize)

  if (length(col) == 2) {
  } else if (length(col) == 3) {
  }

  # add elements to the plot for xy labeling and axis limits
  plot <- plot + xlab(xlab) + ylab(ylab)
  if (!is.null(xlim)) {
    plot <- plot + xlim(xlim[1], xlim[2])
  }
  if (!is.null(ylim)) {
    plot <- plot + ylim(ylim[1], ylim[2])
  }

  # add elements to the plot for title, subtitle, caption
  plot <- plot + labs(title = title, 
    subtitle = subtitle, caption = caption)

  # add elements to the plot for vlines and hlines
  if (!is.null(vline)) {
    plot <- plot + geom_vline(xintercept = vline,
      linetype = vlineType,
      colour = vlineCol,
      size = vlineWidth)
  }
  if (!is.null(hline)) {
    plot <- plot + geom_hline(yintercept = hline,
      linetype = hlineType,
      colour = hlineCol,
      size = hlineWidth)
  }

  # border around plot
  plot <- plot +
    theme(panel.border = element_rect(
      colour = borderColour,
      fill = NA,
      size = borderWidth))

  # gridlines
  if (gridlines.major == TRUE) {
    plot <- plot + theme(panel.grid.major = element_line())
  } else {
    plot <- plot + theme(panel.grid.major = element_blank())
  }
  if (gridlines.minor == TRUE) {
    plot <- plot + theme(panel.grid.minor = element_line())
  } else {
    plot <- plot + theme(panel.grid.minor = element_blank())
  }


  if (!is.null(celllab)) {
    if (drawConnectors == TRUE && is.null(celllab)) {
      plot <- plot + geom_text_repel(
        data = plotobj,
          aes(label = lab),
          size = labSize,
          segment.color = colConnectors,
          segment.size = widthConnectors,
          hjust = labhjust,
          vjust = labvjust)
    } else if (drawConnectors == TRUE && !is.null(celllab)) {
      plot <- plot + geom_text_repel(
        data=subset(plotobj,
          !is.na(plotobj[,'lab'])),
          aes(label = lab),
          size = labSize,
          segment.color = colConnectors,
          segment.size = widthConnectors,
          hjust = labhjust,
          vjust = labvjust)
    } else if (drawConnectors == FALSE && !is.null(celllab)) {
      plot <- plot + geom_text(
        data=subset(plotobj,
          !is.na(plotobj[,'lab'])),
          aes(label = lab),
          size = labSize,
          check_overlap = TRUE,
          hjust = labhjust,
          vjust = labvjust)
    } else if (drawConnectors == FALSE && is.null(celllab)) {
      plot <- plot + geom_text(
        data = plotobj,
          aes(label = lab),
          size = labSize,
          check_overlap = TRUE,
          hjust = labhjust,
          vjust = labvjust)
    }
  }

  return(plot)
}