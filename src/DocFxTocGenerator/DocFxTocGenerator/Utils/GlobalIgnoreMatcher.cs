// <copyright file="GlobalIgnoreMatcher.cs" company="DocFx Companion Tools">
// Copyright (c) DocFx Companion Tools. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>
using DocFxTocGenerator.FileService;
using Microsoft.Extensions.Logging;

namespace DocFxTocGenerator.Utils;

/// <summary>
/// Utility class for matching global ignore patterns.
/// </summary>
public class GlobalIgnoreMatcher
{
    private readonly List<string> _patterns;
    private readonly ILogger _logger;

    /// <summary>
    /// Initializes a new instance of the <see cref="GlobalIgnoreMatcher"/> class.
    /// </summary>
    /// <param name="patterns">Global ignore patterns.</param>
    /// <param name="logger">Logger.</param>
    public GlobalIgnoreMatcher(string[]? patterns, ILogger logger)
    {
        _patterns = patterns?.ToList() ?? new List<string>();
        _logger = logger;
    }

    /// <summary>
    /// Checks if a file or folder should be ignored based on global patterns.
    /// </summary>
    /// <param name="name">Name of the file or folder.</param>
    /// <param name="isFile">Whether the item is a file.</param>
    /// <returns>True if the item should be ignored.</returns>
    public bool ShouldIgnore(string name, bool isFile = false)
    {
        if (_patterns.Count == 0)
        {
            return false;
        }

        foreach (var pattern in _patterns)
        {
            if (MatchesPattern(name, pattern, isFile))
            {
                _logger.LogDebug($"Ignoring '{name}' - matches global pattern '{pattern}'");
                return true;
            }
        }

        return false;
    }

    /// <summary>
    /// Checks if a name matches a specific pattern.
    /// </summary>
    /// <param name="name">Name to check.</param>
    /// <param name="pattern">Pattern to match against.</param>
    /// <param name="isFile">Whether the item is a file.</param>
    /// <returns>True if the name matches the pattern.</returns>
    private bool MatchesPattern(string name, string pattern, bool isFile)
    {
        // Handle exact matches
        if (name.Equals(pattern, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        // Handle wildcard patterns
        if (pattern.Contains('*'))
        {
            return MatchesWildcard(name, pattern);
        }

        // Handle extension patterns (like .design for folders)
        if (pattern.StartsWith('.') && !isFile)
        {
            // For folders, match if folder name ends with the pattern
            if (name.EndsWith(pattern, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }

    /// <summary>
    /// Checks if a name matches a wildcard pattern.
    /// </summary>
    /// <param name="name">Name to check.</param>
    /// <param name="pattern">Wildcard pattern.</param>
    /// <returns>True if the name matches the wildcard pattern.</returns>
    private bool MatchesWildcard(string name, string pattern)
    {
        // Convert wildcard pattern to regex
        string regexPattern = "^" + System.Text.RegularExpressions.Regex.Escape(pattern)
            .Replace("\\*", ".*")
            .Replace("\\?", ".") + "$";

        return System.Text.RegularExpressions.Regex.IsMatch(name, regexPattern, System.Text.RegularExpressions.RegexOptions.IgnoreCase);
    }
}
