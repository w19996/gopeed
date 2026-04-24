package download

import (
	"fmt"
	"path/filepath"
	"strings"

	"github.com/GopeedLab/gopeed/pkg/util"
)

type downloadCategoryExtraConfig struct {
	DownloadCategoriesEnabled bool                     `json:"downloadCategoriesEnabled"`
	DownloadCategories        []downloadCategoryConfig `json:"downloadCategories"`
}

type downloadCategoryConfig struct {
	Path       string   `json:"path"`
	NameKey    string   `json:"nameKey"`
	Extensions []string `json:"extensions"`
	IsDeleted  bool     `json:"isDeleted"`
}

func (d *Downloader) applyResolvedDownloadCategory(task *Task) {
	if task == nil || task.Meta == nil || task.Meta.Opts == nil || task.Meta.Res == nil {
		return
	}

	var extra downloadCategoryExtraConfig
	if err := util.MapToStruct(d.cfg.DownloaderStoreConfig.Extra, &extra); err != nil {
		return
	}
	if !extra.DownloadCategoriesEnabled {
		return
	}

	currentPath := strings.TrimSpace(task.Meta.Opts.Path)
	if !shouldApplyResolvedCategory(extra, d.cfg.DownloaderStoreConfig.DownloadDir, currentPath) {
		d.Logger.Debug().
			Str("taskId", task.ID).
			Str("currentPath", currentPath).
			Str("downloadDir", d.cfg.DownloaderStoreConfig.DownloadDir).
			Msg("download category: skip resolved category because path is not managed")
		return
	}

	fileName := resolvedTaskFileName(task)
	category := matchResolvedDownloadCategory(extra, fileName)
	if category == nil {
		d.Logger.Debug().
			Str("taskId", task.ID).
			Str("fileName", fileName).
			Str("fromPath", currentPath).
			Str("toPath", d.cfg.DownloaderStoreConfig.DownloadDir).
			Msg("download category: fallback to default download dir")
		task.Meta.Opts.Path = d.cfg.DownloaderStoreConfig.DownloadDir
		return
	}
	d.Logger.Debug().
		Str("taskId", task.ID).
		Str("fileName", fileName).
		Str("fromPath", currentPath).
		Str("toPath", category.Path).
		Str("category", category.NameKey).
		Msg("download category: apply resolved category")
	task.Meta.Opts.Path = category.Path
}

func resolvedTaskFileName(task *Task) string {
	if task == nil || task.Meta == nil || task.Meta.Res == nil {
		return ""
	}
	if len(task.Meta.Res.Files) == 0 {
		return strings.TrimSpace(task.Meta.Opts.Name)
	}
	if strings.TrimSpace(task.Meta.Res.Files[0].Name) != "" {
		return task.Meta.Res.Files[0].Name
	}
	if strings.TrimSpace(task.Meta.Res.Name) != "" {
		return task.Meta.Res.Name
	}
	return strings.TrimSpace(task.Meta.Opts.Name)
}

func shouldApplyResolvedCategory(extra downloadCategoryExtraConfig, downloadDir string, currentPath string) bool {
	if !extra.DownloadCategoriesEnabled {
		return false
	}
	if currentPath == "" || sameCategoryPath(currentPath, downloadDir) {
		return true
	}
	for _, category := range extra.DownloadCategories {
		if category.IsDeleted {
			continue
		}
		if sameCategoryPath(category.Path, currentPath) {
			return true
		}
	}
	return false
}

func matchResolvedDownloadCategory(extra downloadCategoryExtraConfig, fileName string) *downloadCategoryConfig {
	fileName = strings.TrimSpace(fileName)
	if fileName == "" {
		return nil
	}

	ext := strings.TrimPrefix(strings.ToLower(filepath.Ext(fileName)), ".")
	if ext == "" {
		return nil
	}

	var otherCategory *downloadCategoryConfig
	for i := range extra.DownloadCategories {
		category := &extra.DownloadCategories[i]
		if category.IsDeleted {
			continue
		}
		if category.NameKey == "categoryOther" {
			otherCategory = category
			continue
		}
		for _, categoryExt := range category.Extensions {
			if strings.EqualFold(strings.TrimPrefix(categoryExt, "."), ext) {
				return category
			}
		}
	}
	return otherCategory
}

func sameCategoryPath(a string, b string) bool {
	a = normalizeCategoryPath(a)
	b = normalizeCategoryPath(b)
	if a == "" || b == "" {
		return a == b
	}
	if same := a == b; same {
		return true
	}
	return strings.EqualFold(a, b)
}

func normalizeCategoryPath(value string) string {
	value = strings.TrimSpace(value)
	if value == "" {
		return ""
	}
	clean := filepath.Clean(value)
	if clean == "." {
		return ""
	}
	return strings.TrimRightFunc(clean, func(r rune) bool {
		return r == '\\' || r == '/'
	})
}

func (c downloadCategoryConfig) String() string {
	return fmt.Sprintf("%s(%s)", c.NameKey, c.Path)
}
