/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM PortfolioProject..NashvilleHousing


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format


SELECT * 
-- SaleDate, CONVERT(date, SaleDate) as ConvertedSaleDate
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD ConvertedSaleDate date;

UPDATE PortfolioProject..NashvilleHousing
SET ConvertedSaleDate = CONVERT(date, SaleDate)



SELECT SaleDate, ConvertedSaleDate
FROM PortfolioProject..NashvilleHousing


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Populate PropertyAddress Data


SELECT * 
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
Order by PropertyAddress



SELECT*
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking out PropertyAddress into Separate Columns (Address, City)


SELECT PropertyAddress
, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , 
LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR (255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )



ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR (255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , 
LEN(PropertyAddress))



SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing



-- Breaking out OwnerAddress into Separate Columns (Address, City, State)


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing



SELECT OwnerAddress
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) City
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) State
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR (255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR (255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Changing 'Y' and 'N' to 'Yes' and 'No' in 'Sold as Vacant' Column


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) Count
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
, CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END Updated
FROM PortfolioProject.dbo.NashvilleHousing
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'
ORDER BY 1



UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



SELECT SoldAsVacant
FROM PortfolioProject.dbo.NashvilleHousing
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'
ORDER BY 1



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove duplicates


SELECT*
, ROW_NUMBER () OVER (
				PARTITION BY ParcelID,
							PropertyAddress,
							SaleDate,
							SalePrice,
							LegalReference
				ORDER BY UniqueID
							) as RowNumber
FROM PortfolioProject.dbo.NashvilleHousing



WITH RowNumberCTE AS(
SELECT*
, ROW_NUMBER () OVER (
				PARTITION BY ParcelID,
							PropertyAddress,
							SaleDate,
							SalePrice,
							LegalReference
				ORDER BY UniqueID
							) as RowNumber
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumberCTE
WHERE RowNumber > 1



WITH RowNumberCTE AS(
SELECT*
, ROW_NUMBER () OVER (
				PARTITION BY ParcelID,
							PropertyAddress,
							SaleDate,
							SalePrice,
							LegalReference
				ORDER BY UniqueID
							) as RowNumber
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumberCTE
WHERE RowNumber > 1



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


SELECT*
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate




