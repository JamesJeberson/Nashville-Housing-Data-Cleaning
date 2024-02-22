
--Cleaning Data Using SQL 

SELECT *
FROM PortfolioProject..Nashville_Housing_Data

--Standardizing Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject..Nashville_Housing_Data

UPDATE PortfolioProject..Nashville_Housing_Data
SET SaleDate = CONVERT(date,Saledate)

ALTER TABLE portfolioProject..Nashville_Housing_Data
ADD SaleDateConverted Date;

UPDATE PortfolioProject..Nashville_Housing_Data
SET SaleDateConverted = CONVERT(date, saledate)

SELECT SaleDateConverted
FROM PortfolioProject..Nashville_Housing_Data

------------------------------------------------------------------------------------------------

--Populate Property Address

SELECT *
FROM PortfolioProject..Nashville_Housing_Data
WHERE PropertyAddress IS NULL

SELECT a.UniqueID, a.ParcelID, a.PropertyAddress,b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville_Housing_Data a
JOIN PortfolioProject..Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville_Housing_Data a
JOIN PortfolioProject..Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------------

--Breaking out address into individual columns (Address, City, State)

--Breaking property address using substring
SELECT 
PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..Nashville_Housing_Data

ALTER TABLE PortfolioProject..Nashville_Housing_Data
ADD 
PropertyAddressConverted nvarchar(255), 
PropertyCityConverted nvarchar(255);

UPDATE PortfolioProject..Nashville_Housing_Data
SET 
PropertyAddressConverted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
PropertyCityConverted = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertyAddress, PropertyAddressConverted, PropertyCityConverted
FROM PortfolioProject..Nashville_Housing_Data

--Breaking owner addresss using Parsename
SELECT
OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) AS State
FROM PortfolioProject..Nashville_Housing_Data

ALTER TABLE PortfolioProject..Nashville_Housing_Data
ADD 
OwnerAddressConverted nvarchar(255), 
OwnerCityConverted nvarchar(255),
OwnerStateConverted nvarchar(255);

UPDATE PortfolioProject..Nashville_Housing_Data
SET
OwnerAddressConverted = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
OwnerCityConverted = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
OwnerStateConverted = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT OwnerAddress, OwnerAddressConverted, OwnerCityConverted, OwnerStateConverted
FROM PortfolioProject..Nashville_Housing_Data

-------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashville_Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..Nashville_Housing_Data

UPDATE PortfolioProject..Nashville_Housing_Data
SET 
SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS
(
SELECT *, 
ROW_NUMBER() OVER (
	PARTITION BY 
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	ORDER BY 
	UniqueID
	) AS RowNum
FROM PortfolioProject..Nashville_Housing_Data
)
SELECT *
FROM RowNumCTE
WHERE RowNum > 1



WITH RowNumCTE AS
(
SELECT *, 
ROW_NUMBER() OVER (
	PARTITION BY 
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	ORDER BY 
	UniqueID
	) AS RowNum
FROM PortfolioProject..Nashville_Housing_Data
)
DELETE
FROM RowNumCTE
WHERE RowNum > 1

---------------------------------------------------------------------------------------------

--Delete unused columns

SELECT *
FROM PortfolioProject..Nashville_Housing_Data

ALTER TABLE PortfolioProject..Nashville_Housing_Data
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate

