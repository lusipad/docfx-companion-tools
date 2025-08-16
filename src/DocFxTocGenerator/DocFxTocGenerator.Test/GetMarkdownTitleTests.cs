using System;
using System.IO;
using DocFxTocGenerator.FileService;
using Microsoft.Extensions.Logging;
using Xunit;

namespace DocFxTocGenerator.Test
{
    public class GetMarkdownTitleTests
    {
        [Fact]
        public void GetMarkdownTitle_ShouldExtractFullTitleIncludingLinks()
        {
            // Arrange
            var testContent = @"# 这是一个包含[链接](http://example.com)和**加粗**的标题

测试内容";
            
            var mockFileService = new MockFileService();
            var logger = new MockLogger();
            var fileInfoService = new FileInfoService(false, true, mockFileService, logger);
            
            // Create test file
            string testFilePath = "test-markdown-title.md";
            mockFileService.WriteAllText(testFilePath, testContent);
            
            // Act
            string result = fileInfoService.GetFileDisplayName(testFilePath, false, true);
            
            // Assert
            Assert.Equal("这是一个包含[链接](http://example.com)和**加粗**的标题", result);
        }
        
        [Fact]
        public void GetMarkdownTitle_ShouldExtractSimpleTitle()
        {
            // Arrange
            var testContent = @"# 简单标题

测试内容";
            
            var mockFileService = new MockFileService();
            var logger = new MockLogger();
            var fileInfoService = new FileInfoService(false, true, mockFileService, logger);
            
            // Create test file
            string testFilePath = "test-simple-title.md";
            mockFileService.WriteAllText(testFilePath, testContent);
            
            // Act
            string result = fileInfoService.GetFileDisplayName(testFilePath, false, true);
            
            // Assert
            Assert.Equal("简单标题", result);
        }
    }
}