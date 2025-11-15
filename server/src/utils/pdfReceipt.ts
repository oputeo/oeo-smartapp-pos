// ADD THIS ROUTE AT THE END OF pos.ts
router.get('/receipt/:id/pdf', async (req: any, res) => {
  try {
    const receipt = await Receipt.findOne({ _id: req.params.id, tenantId: req.tenantId });
    if (!receipt) return res.status(404).json({ msg: 'Receipt not found' });

    const { generatePDFReceipt } = await import('../utils/pdfReceipt');
    const pdfDoc = await generatePDFReceipt(receipt);

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=receipt-${receipt.receiptId}.pdf`);

    pdfDoc.getBuffer((buffer: Buffer) => {
      res.send(buffer);
    });
  } catch (err) {
    res.status(500).json({ msg: 'PDF generation failed' });
  }
});