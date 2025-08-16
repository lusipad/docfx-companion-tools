// <copyright file="LanguageHelper.cs" company="DocFx Companion Tools">
// Copyright (c) DocFx Companion Tools. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// </copyright>
using System.Globalization;

namespace DocFxTocGenerator.Utils;

/// <summary>
/// Helper class for language detection and management.
/// </summary>
public static class LanguageHelper
{
    /// <summary>
    /// Supported languages.
    /// </summary>
    public enum Language
    {
        /// <summary>
        /// English language.
        /// </summary>
        English,

        /// <summary>
        /// Chinese language.
        /// </summary>
        Chinese,
    }

    /// <summary>
    /// Gets the default language based on system culture.
    /// </summary>
    /// <returns>The default language.</returns>
    public static Language GetDefaultLanguage()
    {
        var currentCulture = CultureInfo.CurrentCulture;

        // Check if the culture is Chinese
        if (currentCulture.Name.StartsWith("zh", StringComparison.OrdinalIgnoreCase))
        {
            return Language.Chinese;
        }

        // Check if the culture is English
        if (currentCulture.Name.StartsWith("en", StringComparison.OrdinalIgnoreCase))
        {
            return Language.English;
        }

        // For other cultures, default to Chinese as requested
        return Language.Chinese;
    }

    /// <summary>
    /// Parses language from string.
    /// </summary>
    /// <param name="languageString">The language string.</param>
    /// <returns>The parsed language.</returns>
    public static Language ParseLanguage(string languageString)
    {
        return languageString.ToLowerInvariant() switch
        {
            "en" or "english" => Language.English,
            "zh" or "chinese" or "中文" => Language.Chinese,
            _ => GetDefaultLanguage(),
        };
    }

    /// <summary>
    /// Gets the language code for the specified language.
    /// </summary>
    /// <param name="language">The language.</param>
    /// <returns>The language code.</returns>
    public static string GetLanguageCode(Language language)
    {
        return language switch
        {
            Language.English => "en",
            Language.Chinese => "zh",
            _ => "zh",
        };
    }

    /// <summary>
    /// Gets the display name for the specified language.
    /// </summary>
    /// <param name="language">The language.</param>
    /// <returns>The display name.</returns>
    public static string GetDisplayName(Language language)
    {
        return language switch
        {
            Language.English => "English",
            Language.Chinese => "中文",
            _ => "中文",
        };
    }
}
