using System.CodeDom.Compiler;
using System.IO;
using DocFxTocGenerator.FileService;
using DocFxTocGenerator.TableOfContents;
using DocFxTocGenerator.Test.Helpers;
using Microsoft.Extensions.Logging;
using Xunit;

namespace DocFxTocGenerator.Test;

public class TocOutputFormatTests
{
    [Fact]
    public async Task WriteTocFileAsync_ShouldStartWithItemsHeader()
    {
        // Arrange
        var mockFileService = new MockFileService();
        var logger = new MockLogger();
        var outputFolder = "test-output";
        
        // Create test folder structure
        var rootFolder = new FolderData("root", "root", 0);
        var subFolder = new FolderData("sub", "root/sub", 1);
        var file1 = new FileData("file1.md", "root/file1.md", 0);
        var file2 = new FileData("file2.md", "root/sub/file2.md", 0);
        
        rootFolder.Files.Add(file1);
        rootFolder.Folders.Add(subFolder);
        subFolder.Files.Add(file2);
        
        var tocItem = new TocItem
        {
            Name = "Root",
            Href = "root/index.md",
            Base = rootFolder,
            Depth = 0
        };
        
        // Add child items
        var file1Item = new TocItem
        {
            Name = "File 1",
            Href = "root/file1.md",
            Base = file1,
            Depth = 0
        };
        
        var subFolderItem = new TocItem
        {
            Name = "Sub Folder",
            Href = "root/sub/index.md",
            Base = subFolder,
            Depth = 0
        };
        
        var file2Item = new TocItem
        {
            Name = "File 2",
            Href = "root/sub/file2.md",
            Base = file2,
            Depth = 0
        };
        
        subFolderItem.Items.Add(file2Item);
        tocItem.Items.Add(file1Item);
        tocItem.Items.Add(subFolderItem);
        
        var service = new TableOfContentsService(outputFolder, TocFolderReferenceStrategy.Index, TocOrderStrategy.All, mockFileService, logger);
        
        // Act
        await service.WriteTocFileAsync(tocItem, 0);
        
        // Assert
        string tocFilePath = Path.Combine(outputFolder, "toc.yml");
        string tocContent = mockFileService.ReadAllText(tocFilePath);
        
        // Check that the file starts with the expected format
        string[] lines = tocContent.Split('\n');
        Assert.Equal("# This is an automatically generated file", lines[0].Trim());
        Assert.Equal("items:", lines[1].Trim());
        
        // Check that the content contains expected items
        Assert.Contains("- name: Root", tocContent);
        Assert.Contains("- name: File 1", tocContent);
        Assert.Contains("- name: Sub Folder", tocContent);
    }
}